require "./syntax/location.cr"
require "./syntax/ast.cr"
require "./source-highlight.cr"
require "./interpreter/context.cr"
require "colorize"

module Charly
  # The base for all exceptions in charly
  class BaseException < Exception
    def to_s(io)
      meta(io)
      io << "#{@message}".colorize(:red)
    end

    # :nodoc:
    private def meta(io)
    end
  end

  # `LocalException` is the base type for all exceptions that can highlight
  # parts of a file
  class LocalException < BaseException
    property location_start : Location
    property location_end : Location
    property source : String
    property filename : String
    property trace : Array(Trace)

    def initialize(@location_start, @location_end, @message, @trace = [] of Trace)
      path = @location_start.filename

      if path.starts_with? Dir.current
        @filename = File.join(".", path.gsub(Dir.current, ""))
      else
        @filename = path
      end

      # Load the file at the path of @location_start

      if File.exists?(path) && File.readable?(path)
        @source = File.read(path)
      else
        @source = ""
      end
    end

    def self.new(location_start : Location, message : String)
      self.new(location_start, location_start, message)
    end

    def self.new(node : ASTNode, message : String)
      self.new(node.location_start, node.location_end, message)
    end

    def self.new(node : ASTNode, context : Context, message : String)
      self.new(node.location_start, node.location_end, message, context.trace)
    end

    private def meta(io)
      # Print the filename
      io << @filename.colorize(:yellow)
      io << "\n"

      # Print the source highlight
      loc_start, loc_end = nil, nil
      if (source = @source).is_a? String
        # They both might be set to null, so check first
        loc_start, loc_end = @location_start, @location_end
        if loc_start.is_a?(Location) && loc_end.is_a?(Location)
          highlighter = SourceHighlight.new(loc_start, loc_end)
          highlighter.present(source, io)
        end
      end

      # Print the stack trace
      @trace.each do |entry|
        io << "#{entry.colorize(:green)}\n"
      end
      io << "at #{loc_start}\n".colorize(:green)
    end
  end

  #  A `SyntaxError` describes unexpected chars or tokens in the source string
  class SyntaxError < LocalException
  end

  # A `InvalidNode` describes unexpected nodes in a parse tree
  class RunTimeError < LocalException
  end
end
