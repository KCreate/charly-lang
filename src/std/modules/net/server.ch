const net_create = __internal__method("net_create")
const net_listen = __internal__method("net_listen")
const net_close = __internal__method("net_close")

const Request = require("./request.ch")
const Response = require("./response.ch")

class Server {
  property id
  property address
  property port
  property events

  func constructor(address, port) {
    @id = net_create(self, address, port)
    @address = address
    @port = port
    @events = {}
  }

  func listen() {
    net_listen(@id)
  }

  func close() {
    net_close(@id)
  }

  func on(name, callback) {
    @events[name] = callback
  }

  /*
   * This is the method net_listen will delegate any events to
   **/
  func invoke(name, arguments) {
    const handler = @events[name]

    if typeof handler == "Function" {

      if name == "request" {
        const request = arguments[0]
        const response = arguments[1]

        // Both request and response are wrapped in their own
        // objects so we can have methods on them
        const wrapped_request = arguments[0] = Request(arguments[0])
        const wrapped_response = arguments[1] = Response(arguments[1])

        const result = handler.run(arguments)

        // Copies over all keys from the wrapped response
        // to the original response object provided by
        // the native functions
        Object.keys(wrapped_response).each(->(key) {
          response[key] = wrapped_response[key]
        })

        return result
      } else {
        return handler.run(arguments)
      }
    }
  }
}

export = Server
export.Request = Request
export.Response = Response
