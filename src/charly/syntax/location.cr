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
      io << "#{@filename}:"
      io << "#{@row}:#{@column}:#{@length}".ljust(9, ' ')
    end
  end
end
