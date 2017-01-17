module Charly

  # Single trace entry for callstacks
  class Trace
    property name : String
    property filename : String
    property location : String

    def initialize(@name, @filename, @location)
    end

    def to_s(io)
      io << "at #{@name} (#{@filename}:#{@location})"
    end
  end

end
