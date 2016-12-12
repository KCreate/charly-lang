require "./location.cr"

module Charly

  # Mapping between operators and function names you use to override them
  OPERATOR_MAPPING = {

    # Arithmetic
    TokenType::Plus  => "__plus",
    TokenType::Minus => "__minus",
    TokenType::Mult  => "__mult",
    TokenType::Divd  => "__divd",
    TokenType::Mod   => "__mod",
    TokenType::Pow   => "__pow",

    # Comparison
    TokenType::Less         => "__less",
    TokenType::Greater      => "__greater",
    TokenType::LessEqual    => "__lessequal",
    TokenType::GreaterEqual => "__greaterequal",
    TokenType::Equal        => "__equal",
    TokenType::Not          => "__not",
  }

  # Mapping between unary operators and function names you use to override them
  UNARY_OPERATOR_MAPPING = {
    TokenType::Plus  => "__uplus",
    TokenType::Minus => "__uminus",
    TokenType::Not   => "__unot",
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
      when AtSign
        io << "@"
      when AndSign
        io << "&"
      when RightArrow
        io << "->"
      when LeftArrow
        io << "<-"
      else
        io << super
      end
    end

    # Returns true if this is a regular operator
    def regular_overrideable
      OPERATOR_MAPPING.has_key? self
    end

    # Returns true if this is a unary operator
    def unary_overrideable
      UNARY_OPERATOR_MAPPING.has_key? self
    end

    # Returns true if this operator can be overridden
    def overrideable
      regular_overrideable || unary_overrideable
    end

    # Returns the overrideable method name of this operator
    def method_name
      OPERATOR_MAPPING[self]
    end

    # Returns the overrideable method name of this unary operator
    def unary_method_name
      UNARY_OPERATOR_MAPPING[self]
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
