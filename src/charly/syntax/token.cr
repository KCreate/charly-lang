require "./location.cr"

module Charly

  # Mapping between and assignment operators and real operators
  AND_ASSIGNMENT_MAPPING = {
    TokenType::PlusAssignment  => TokenType::Plus,
    TokenType::MinusAssignment => TokenType::Minus,
    TokenType::MultAssignment  => TokenType::Mult,
    TokenType::DivdAssignment  => TokenType::Divd,
    TokenType::ModAssignment   => TokenType::Mod,
    TokenType::PowAssignment   => TokenType::Pow,
  }

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

    # Bitwise operators
    # The & operator is parsed as the AndSign
    BitOR
    BitXOR
    BitNOT
    BitAND
    LeftShift
    RightShift

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
    RightArrow
    LeftArrow
    QuestionMark
    Colon

    # Whitespace
    Whitespace
    Newline

    # Misc
    EOF
    Unknown

    def and_operator?
      AND_ASSIGNMENT_MAPPING.has_key? self
    end

    def and_real_operator
      AND_ASSIGNMENT_MAPPING[self]
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
