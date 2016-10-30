require "./token.cr"
require "./reader.cr"
require "../exceptions.cr"

module Charly

  # The `Lexer` turns a sequence of chars into a list
  # of tokens
  class Lexer
    property tokens : Array(Token)
    property reader : Reader
    property filename : String
    property token : Token
    property row : Int32
    property column : Int32
    property last_char : Char

    def initialize(source : IO, @filename : String)
      @token = Token.new
      @tokens = [] of Token
      @reader = Reader.new(source)

      @row = 1
      @column = 1
      @last_char = ' '
    end

    # Creates a new lexer with a String as the source
    def self.new(source : String, filename : String)
      self.new(MemoryIO.new(source), filename)
    end

    # Returns the current char
    def current_char
      @reader.current_char
    end

    # Read the next char without writing to the buffer
    # or incrementing any positions
    def peek_char
      @reader.peek_char
    end

    # Returns the next char in the reader
    def read_char
      last_char = current_char
      @column += 1

      if last_char == '\n'
        @row += 1
        @column = 1
      end

      @reader.read_char
    end

    # Returns the next char and updates the type of the current token
    def read_char(type : TokenType)
      @token.type = type
      read_char
    end

    # Resets the current token
    def reset_token
      @token = Token.new
      @token.type = TokenType::Unknown
      @token.value = ""
      @token.raw = ""
      @token.location = Location.new
    end

    # Return the next token in the source
    def read_token
      reset_token
      @token.location.pos = @reader.pos + 1

      case current_char
      when '\0'
        read_char TokenType::EOF
      when ' ', '\t'
        consume_whitespace
      when '\r'
        consume_newline
      when '\n'
        consume_newline
      when ';'
        read_char TokenType::Semicolon
      when ','
        read_char TokenType::Comma
      when '.'
        read_char TokenType::Point
      when '"'
        consume_string
      when '0'..'9'
        consume_numeric
      when '+'
        consume_operator_or_assignment TokenType::Plus
      when '-'
        consume_operator_or_assignment TokenType::Minus
      when '/'
        consume_operator_or_assignment TokenType::Divd
      when '*'
        case read_char
        when '*'
          consume_operator_or_assignment TokenType::Pow
        else
          @token.type = TokenType::Mult
        end
      when '%'
        consume_operator_or_assignment TokenType::Mod
      when '='
        case read_char
        when '='
          read_char TokenType::Equal
        else
          @token.type = TokenType::Assignment
        end
      when '&'
        case read_char
        when '&'
          @token.type = TokenType::AND
        end
      when '|'
        case read_char
        when '|'
          @token.type = TokenType::OR
        end
      when '!'
        read_char TokenType::Not
      when '<'
        case read_char
        when '='
          read_char TokenType::LessEqual
        else
          @token.type = TokenType::Less
        end
      when '>'
        case read_char
        when '='
          read_char TokenType::GreaterEqual
        else
          @token.type = TokenType::Greater
        end
      when '('
        read_char TokenType::LeftParen
      when ')'
        read_char TokenType::RightParen
      when '{'
        read_char TokenType::LeftCurly
      when '}'
        read_char TokenType::RightCurly
      when '['
        read_char TokenType::LeftBracket
      when ']'
        read_char TokenType::RightBracket
      when '#'
        consume_comment
      else
        if ident_start(current_char)
          consume_ident
        else
          unexpected_char
        end
      end

      @token.raw = @reader.buffer.to_s[0..-2]
      @token.location.row = @row
      @token.location.column = @column - (@token.raw.size - 1)
      @token.location.length = @token.raw.size
      @token.location.filename = @filename

      @reader.reset
      @reader.buffer << current_char

      @tokens << @token
      @token
    end

    # Consumes operators or AND assignments
    def consume_operator_or_assignment(operator : TokenType)
      if read_char == '='
        case operator
        when TokenType::Plus
          read_char TokenType::PlusAssignment
        when TokenType::Minus
          read_char TokenType::MinusAssignment
        when TokenType::Mult
          read_char TokenType::MultAssignment
        when TokenType::Divd
          read_char TokenType::DivdAssignment
        when TokenType::Mod
          read_char TokenType::ModAssignment
        when TokenType::Pow
          read_char TokenType::PowAssignment
        else
          read_char operator
        end
      else
        @token.type = operator
      end
    end

    # Consumes whitespaces (space and tabs)
    def consume_whitespace
      @token.type = TokenType::Whitespace

      # Read as many whitespaces as possible
      loop do
        case read_char
        when ' ', '\t'
          # Nothing to do
        else
          break
        end
      end
    end

    # Consumes newlines
    def consume_newline
      @token.type = TokenType::Newline

      loop do
        case current_char
        when '\n'
          read_char
        when '\r'
          case read_char
          when '\n'
            read_char
          else
            unexpected_char
          end
        else
          break
        end
      end
    end

    # Consumes Integer and Float values
    def consume_numeric
      @token.type = TokenType::Numeric
      has_underscore = false

      loop do
        case read_char
        when .digit?
          # Nothing to do
        when '_'
          has_underscore = true
        else
          break
        end
      end

      if current_char == '.' && peek_char.digit?
        read_char
        loop do
          case read_char
          when .digit?
            # Nothing to do
          when '_'
            has_underscore = true
          else
            break
          end
        end
      end

      number_value = @reader.buffer.to_s[0..-2]

      if has_underscore
        number_value = number_value.tr("_", "")
      end

      @token.value = number_value
    end

    # Consume a string literal
    def consume_string

      @token.type = TokenType::String

      initial_row = @row
      initial_column = @column
      initial_pos = @reader.pos

      loop do
        case char = read_char
        when '\\'
        when '"'
          break
        when '\0'
          # Create a location for the presenter to show
          loc = Location.new
          loc.filename = @filename
          loc.row = initial_row
          loc.column = initial_column
          loc.pos = initial_pos
          loc.length = (@reader.pos - initial_pos).to_i32

          raise SyntaxError.new(loc, "Unclosed string")
        end
      end

      @token.value = @reader.buffer.to_s[1..-2]
      read_char
    end

    # Consumes a single line comment
    def consume_comment
      @token.type = TokenType::Comment

      loop do
        case read_char
        when '\n'
          break
        when '\r'
          case read_char
          when '\n'
            break
          else
            unexpected_char
          end
        else
          # Nothing to do
        end
      end

      @token.value = @reader.buffer.to_s[0..-2]
    end

    # Consume an identifier
    def consume_ident
      while ident_part(current_char)
        read_char
      end

      @token.type = TokenType::Identifier
      @token.value = @reader.buffer.to_s[0..-2]
    end

    # Returns true if *char* could be the start of an identifier
    def ident_start(char : Char)
      char.alpha? || char == '_' || char == '$' || char.ord > 0x9F
    end

    # Returns true if *char* could be inside an identifier
    def ident_part(char : Char)
      ident_start(char) || char.digit? || char == '$'
    end

    # Checks if the current buffer is a keyword of an identifier
    def check_ident_or_keyword(symbol)
      if ident_part(peek_char)
        consume_ident
      else
        read_char
        @token.type = symbol
        @token.value = @reader.buffer.to_s[0..-2]
      end
    end

    # Called when an unexpected char was read
    def unexpected_char

      # Create a location
      loc = Location.new
      loc.filename = @filename
      loc.row = @row
      loc.column = @column
      loc.length = 1

      raise SyntaxError.new(loc, "Unexpected '#{current_char}'")
    end

    # Dump all tokens to STDOUT
    def token_dump
      @tokens.each do |token|
        puts token
      end
    end
  end
end
