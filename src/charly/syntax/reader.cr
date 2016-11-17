module Charly

  # UTF-8 wrapper around MemoryIO and File
  class Reader
    property source : File | MemoryIO
    property buffer : MemoryIO
    property pos : UInt32
    property current_char : Char

    def initialize(@source)
      @pos = 0_u32
      @buffer = MemoryIO.new
      @current_char = read_char
    end

    # Initiate a new `Reader` from a string
    def self.new(source : String)
      self.new(MemoryIO.new(source))
    end

    # Reads the next char from the source
    def read_char
      char = @source.read_char

      # When we reached the end of the file,
      # we just return an endless stream of null bytes
      unless char.is_a? Char
        char = '\0'
      end

      @current_char = char
      @pos += 1
      @buffer << char

      char
    end

    # Reads the next char from the source without advancing the position
    def peek_char
      char = @source.read_char

      # When we reached the end of the file,
      # we just return an endless stream of null bytes
      unless char.is_a? Char
        char = '\0'
      end

      unless source.size == 0
        source.pos -= 1
      end

      char
    end

    # Reads the whole source until an EOF is found
    # The eof won't be added to the buffer
    def finish
      until peek_char == '\0'
        read_char
      end

      self
    end

    # Close File handles or clear the MemoryIO
    def clear
      if (source = @source).is_a? File
        source.close
      end
    end
  end

  # Same as `Reader` but keeps a window to the buffer
  # The window can be closed and grows when new data is added to the buffer
  class FramedReader < Reader
    property frame : MemoryIO
    property pos_frame : UInt32

    def initialize(source)
      @frame = MemoryIO.new
      super
      @pos_frame = @pos
    end

    # :ditto:
    def read_char
      char = super
      @frame << char
      char
    end

    def reset
      @frame.clear
      @pos_frame = @pos
    end
  end
end
