require "./location.cr"

module Charly

  enum TokenType

    # Literals
    Numeric
    Identifier
    String
    Boolean
    Null
    NAN
    Keyword

    # Operators
    Plus
    Minus
    Mult
    Divd
    Mod
    Pow
    Assignment

    # AND assignments
    PlusAssignment
    MinusAssignment
    MultAssignment
    DivdAssignment
    ModAssignment
    PowAssignment

    # Comparison
    Equal
    Not
    Less
    Greater
    LessEqual
    GreaterEqual
    AND
    OR

    # Structure
    LeftParen, RightParen
    LeftCurly, RightCurly
    LeftBracket, RightBracket
    Semicolon
    Comma
    Point
    Comment

    # Whitespace
    Whitespace
    Newline

    # Misc
    EOF
    Unknown
  end

  struct Token
    property type : TokenType
    property value : String
    property raw : String
    property passed_return : Bool
    property location : Location

    def initialize(@type = TokenType::Unknown, @value = "", @raw = "", @passed_return = false)
      @location = Location.new
    end

    def to_s(io)
      io << "#{@location}"
      io << " │ "

      io << "#{@type.to_s.ljust(12, ' ')}"
      io << "│ "
      io << "#{@raw.strip}"
    end

    def inspect(io)
      io << "#{@type}:#{@raw.strip}"
    end
  end
end
