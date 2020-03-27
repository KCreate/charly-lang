require "../**"
require "colorize"
require "http"

module Charly::Internals

  # Pool of all current open servers
  HTTP_SERVERS = {} of UInt64 => Server
  HTTP_RESPONSES = {} of UInt64 => HTTP::Server::Response

  class Server
    # TODO: Put these at a more suitable place
    @@next_server_id = 1_u64
    @@next_response_id = 1_u64

    def self.next_server_id
      @@next_server_id
    end

    def self.next_server_id=(value)
      @@next_server_id = value
    end

    def self.next_response_id
      @@next_response_id
    end

    def self.next_response_id=(value)
      @@next_response_id = value
    end

    property server : HTTP::Server
    property handler : TObject
    property on_request : Proc(TObject, TObject, Void)?
    property on_listen : Proc(Void)?
    property on_close : Proc(Void)?

    def initialize(@handler, address, port)
      @server = HTTP::Server.new(address, port) do |context|

        # Registers this response in the global response table
        response_id = Server.next_response_id
        HTTP_RESPONSES[response_id] = context.response
        Server.next_response_id += 1

        # Wraps request and response objects to be passed to charly space
        wrapped_request = wrap_request context.request
        wrapped_response = wrap_response context.response, response_id
        @on_request.try &.call wrapped_request, wrapped_response

        unless context.response.output.closed?
          copy_to_response wrapped_response, context.response
        end

        HTTP_RESPONSES.delete response_id
      end
    end

    def on_request(&block : Proc(TObject, TObject, Void))
      @on_request = block
    end

    def on_listen(&block)
      @on_listen = block
    end

    def on_close(&block)
      @on_close = block
    end

    def listen
      @server.listen
    end

    def close
      @server.close
    end

    # Creates a TObject from a HTTP::Request
    private def wrap_request(req : HTTP::Request)
      TObject.new do |data|
        data.init "body",           TString.new  req.body.to_s
        data.init "content_length", TNumeric.new req.content_length || 0
        data.init "host",           TString.new  req.host || ""
        data.init "ignore_body",    TBoolean.new req.ignore_body?
        data.init "keep_alive",     TBoolean.new req.keep_alive?
        data.init "method",         TString.new  req.method
        data.init "path",           TString.new  req.path
        data.init "query",          TString.new  req.query || ""
        data.init "resource",       TString.new  req.resource
        data.init "version",        TString.new  req.version

        data.init "query_params", TObject.new { |data|
          req.query_params.each do |(name, value)|
            data.init name, TString.new value
          end
        }

        data.init "headers", TObject.new { |data|
          req.headers.each do |(name, value)|
            values = TArray.new value.map { |field| TString.new(field).as(BaseType) }
            data.init name, values
          end
        }

        data.init "cookies", TObject.new { |data|
          req.cookies.each do |cookie|
            data.init cookie.name, TObject.new { |data|
              data.init "value",      TString.new cookie.value
              data.init "path",       TString.new cookie.path
              data.init "secure",     TBoolean.new cookie.secure
              data.init "http_only",  TBoolean.new cookie.http_only

              expires, domain, extension = cookie.expires, cookie.domain, cookie.extension

              data.init "expires", TNumeric.new expires.epoch if expires
              data.init "domain", TString.new domain if domain
              data.init "extension", TString.new extension if extension
            }
          end
        }
      end
    end

    # Creates a TObject from a HTTP::Server::Response
    private def wrap_response(res : HTTP::Server::Response, response_id : UInt64)
      TObject.new do |data|
        data.init "__response_id",  TNumeric.new response_id
        data.init "status_code",    TNumeric.new 200
        data.init "body",           TString.new ""

        data.init "headers", TObject.new { |data|
          res.headers.each do |(name, value)|
            values = TArray.new value.map { |field| TString.new(field).as(BaseType) }
            data.init name, values
          end
        }

        res.headers.clear
      end
    end

    # Copies values from a TObject into a HTTP::Server::Response object
    private def copy_to_response(source : TObject, res : HTTP::Server::Response)
      if source.data.contains "status_code"
        status_code = source.data["status_code"]

        if status_code.is_a? TNumeric
          res.status_code = status_code.value.to_i32
        end
      end

      if source.data.contains "body"
        body = source.data["body"]
        body = "#{body}"
        res.output.print body
      end

      if source.data.contains "headers"
        headers = source.data["headers"]

        if headers.is_a? TObject
          headers.data.dump_values(false).each do |(_, key, value, _)|

            if value.is_a? TArray
              value.value.each do |field|

                if field.is_a? TString
                  res.headers.add key, field.value
                end
              end
            end
          end
        end
      end
    end
  end

  charly_api "net_create", TObject, TString, TNumeric do |handler, address, port|
    address, port = address.value, port.value.to_i32

    server = Server.new handler, address, port
    event_handler = handler.data.get "invoke"

    server.on_request do |request, response|
      invoke = event_handler.as(TFunc)
      visitor.run_function_call(
        invoke,
        [
          TString.new("request"),
          TArray.new([request, response] of BaseType)
        ] of BaseType,
        server.handler,
        invoke.parent_scope,
        context,
        call.location_start
      )
    end

    server.on_listen do
      invoke = event_handler.as(TFunc)
      visitor.run_function_call(
        invoke,
        [
          TString.new("listen"),
          TArray.new
        ] of BaseType,
        server.handler,
        invoke.parent_scope,
        context,
        call.location_start
      )
    end

    server.on_close do
      invoke = event_handler.as(TFunc)
      visitor.run_function_call(
        invoke,
        [
          TString.new("close"),
          TArray.new
        ] of BaseType,
        server.handler,
        invoke.parent_scope,
        context,
        call.location_start
      )
    end

    HTTP_SERVERS[Server.next_server_id] = server
    return TNumeric.new(Server.next_server_id).tap do
      Server.next_server_id += 1
    end
  end

  charly_api "net_listen", TNumeric do |id|
    id = id.value.to_u64

    server = HTTP_SERVERS[id]?

    if server
      server.on_listen.try &.call
      server.listen
    end

    TNull.new
  end

  charly_api "net_close", TNumeric do |id|
    id = id.value.to_u64

    server = HTTP_SERVERS[id]?

    if server
      server.close
      server.on_close.try &.call
    end

    TNull.new
  end

  charly_api "net_response_close", TNumeric do |rid|
    response = HTTP_RESPONSES[rid.value.to_i32]?

    unless response
      raise RunTimeError.new(call, context, "No response with id #{rid}")
    end

    response.close

    TNull.new
  end
end
