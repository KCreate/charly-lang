module Charly
  struct Location
    property pos : UInt32
    property row : Int32
    property column : Int32
    property length : Int32
    property filename : String

    def initialize(@pos = 0_u32, @row = 0, @column = 0, @length = 0, @filename = "virtual")
    end

    def to_s(io)
      io << "#{File.basename(@filename)}:"
      loc_to_s(io)
    end

    def loc_to_s(io)
      io << "#{@row + 1}:#{@column + 1}:#{@length}"
    end

    # :nodoc:
    def loc_to_s
      io = MemoryIO.new
      loc_to_s(io)
      io.to_s
    end
  end
end
