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
    AtSign
    AndSign
    RightArrow
    LeftArrow

    # Whitespace
    Whitespace
    Newline

    # Misc
    EOF
    Unknown

    # :nodoc:
    def to_s(io)
      case self
      when Greater
        io << ">"
      when Less
        io << "<"
      when GreaterEqual
        io << ">="
      when LessEqual
        io << "<="
      else
        io << super
      end
    end

    def is_operator?
      Visitor::OPERATOR_MAPPING.has_key? self
    end

    def unary_possible?
      Visitor::UNARY_OPERATOR_MAPPING.has_key? self
    end
  end

  class Token
    property type : TokenType
    property value : String
    property raw : String
    property passed_return : Bool
    property location : Location

    def initialize(@type = TokenType::Unknown, @value = "", @raw = "", @passed_return = false)
      @location = Location.new
    end

    def to_s(io)
      io << "#{@location.loc_to_s.ljust(9, ' ')}"
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
