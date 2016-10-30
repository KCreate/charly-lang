module Charly

  # A `Reader` reads from a String or any IO
  # It keeps read data inside an internal cache
  struct Reader
    property source : File | MemoryIO
    property pos : UInt32
    property pos_buffer : UInt32
    property buffer : MemoryIO
    property current_char : Char

    def initialize(@source : File | MemoryIO)
      @pos = 0_u32
      @pos_buffer = 0_u32
      @buffer = MemoryIO.new
      @current_char = read_char
    end

    def self.new(source : String)
      self.new(MemoryIO.new(source))
    end

    # Reads a char from the source
    # Returns a null byte if no char was read
    def read_char
      char = source.read_char

      unless char.is_a? Char
        char = '\0'
      end

      @buffer << char
      @current_char = char
      @pos += 1_u32

      char
    end

    # Read a char without adding to the internal buffer
    # or incrementing the pos counter
    def peek_char
      char = source.read_char

      unless char.is_a? Char
        char = '\0'
      end

      source.pos -= 1
      char
    end

    # Resets the internal buffer to the current position
    def reset
      @buffer.clear
      @pos_buffer = @pos
      @buffer
    end

    # Rewinds the source IO
    def rewind
      @source.rewind
      @buffer
    end
  end
end
