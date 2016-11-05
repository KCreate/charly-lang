require "./syntax/location.cr"
require "./syntax/ast.cr"
require "./source-highlight.cr"

module Charly

  # The base for all exceptions in charly
  class BaseException < Exception
    def to_s(io)
      io << "#{self.class.name.split("::").last}\n".colorize(:red)
      meta(io)
      io << "#{@message}".colorize(:red)
    end

    # :nodoc:
    private def meta(io)
    end
  end

  # `IOException` is thrown when a file could not be read
  class IOException < BaseException
  end

  # `LocalException` is the base type for all exceptions that can highlight
  # parts of a file
  class LocalException < BaseException
    property location_start : Location
    property location_end : Location
    property source : String

    def initialize(@location_start, @location_end, @source, @message)
    end

    def self.new(location_start : Location, source : String, message : String)
      self.new(location_start, location_start, source, message)
    end

    def self.new(node : ASTNode, source : String, message : String)
      self.new(node.location_start, node.location_end, source, message)
    end

    private def meta(io)
      if (source = @source).is_a? String
        loc_start, loc_end = @location_start, @location_end
        if loc_start.is_a?(Location) && loc_end.is_a?(Location)
          highlighter = SourceHighlight.new(loc_start, loc_end)
          highlighter.present(source, io)
        end
      end
    end
  end

  # A `SyntaxError` describes unexpected chars or tokens in the source string
  class SyntaxError < LocalException
  end

  # A `InvalidNode` describes unexpected nodes in a parse tree
  class RunTimeError < LocalException
  end
end
