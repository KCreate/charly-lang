require "./token.cr"
require "./reader.cr"
require "../exception.cr"

module Charly
  # The `Lexer` turns a sequence of chars into a list of tokens
  class Lexer
    property reader : FramedReader
    property filename : String
    property token : Token
    property tokens : Array(Token)
    property row : Int32
    property column : Int32
    property last_char : Char

    def initialize(source : IO, @filename : String)
      @token = Token.new
      @tokens = [] of Token
      @reader = FramedReader.new(source)

      @row = 0
      @column = 0
      @last_char = ' '
    end

    # Creates a new lexer with a String as the source
    def self.new(source : String, filename : String)
      self.new(IO::Memory.new(source), filename)
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
        @column = 0
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
      @token.location.pos = @reader.pos - 1
      @token.location.row = @row
      @token.location.column = @column
      @token.location.filename = @filename
    end

    # Return the next token in the source
    def read_token
      reset_token

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
        consume_string(@row, @column, @token.location.pos)
      when '0'..'9'
        consume_numeric
      when '+'
        consume_operator_or_assignment TokenType::Plus
      when '-'
        case peek_char
        when '>'
          read_char
          read_char TokenType::RightArrow
        else
          consume_operator_or_assignment TokenType::Minus
        end
      when '/'
        case peek_char
        when '/'
          read_char
          consume_comment
        when '*'
          read_char
          consume_multiline_comment
        else
          consume_operator_or_assignment TokenType::Divd
        end
      when '*'
        case peek_char
        when '*'
          read_char
          consume_operator_or_assignment TokenType::Pow
        else
          consume_operator_or_assignment TokenType::Mult
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
        case peek_char
        when '&'
          read_char
          read_char TokenType::AND
        else
          read_char TokenType::AndSign
        end
      when '|'
        case read_char
        when '|'
          read_char TokenType::OR
        end
      when '!'
        read_char TokenType::Not
      when '<'
        case read_char
        when '='
          read_char TokenType::LessEqual
        when '-'
          read_char TokenType::LeftArrow
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
        consume_comment # TODO: Deprecate this in a future patch
      when '@'
        read_char TokenType::AtSign
      when '?'
        read_char TokenType::QuestionMark
      when ':'
        read_char TokenType::Colon
      when 'b'
        if read_char == 'r' && read_char == 'e' && read_char == 'a' && read_char == 'k'
          check_ident_or_keyword(TokenType::Keyword)
        else
          consume_ident
        end
      when 'c'
        case read_char
        when 'a'
          case read_char
          when 't'
            if read_char == 'c' && read_char == 'h'
              check_ident_or_keyword(TokenType::Keyword)
            else
              consume_ident
            end
          when 's'
            if read_char == 'e'
              check_ident_or_keyword(TokenType::Keyword)
            else
              consume_ident
            end
          else
            consume_ident
          end
        when 'l'
          if read_char == 'a' && read_char == 's' && read_char == 's'
            check_ident_or_keyword(TokenType::Keyword)
          else
            consume_ident
          end
        when 'o'
          case read_char
          when 'n'
            case read_char
            when 's'
              case read_char
              when 't'
                check_ident_or_keyword(TokenType::Keyword)
              else
                consume_ident
              end
            when 't'
              if read_char == 'i' && read_char == 'n' && read_char == 'u' && read_char == 'e'
                check_ident_or_keyword(TokenType::Keyword)
              else
                consume_ident
              end
            else
              consume_ident
            end
          else
            consume_ident
          end
        else
          consume_ident
        end
      when 'd'
        if read_char == 'e' && read_char == 'f' && read_char == 'a' && read_char == 'u' && read_char == 'l' && read_char == 't'
          check_ident_or_keyword(TokenType::Keyword)
        else
          consume_ident
        end
      when 'e'
        case read_char
        when 'l'
          if read_char == 's' && read_char == 'e'
            check_ident_or_keyword(TokenType::Keyword)
          else
            consume_ident
          end
        when 'x'
          if read_char == 't' && read_char == 'e' && read_char == 'n' && read_char == 'd' && read_char == 's'
            check_ident_or_keyword(TokenType::Keyword)
          else
            consume_ident
          end
        else
          consume_ident
        end
      when 'f'
        case read_char
        when 'u'
          if read_char == 'n' && read_char == 'c'
            check_ident_or_keyword(TokenType::Keyword)
          else
            consume_ident
          end
        when 'a'
          if read_char == 'l' && read_char == 's' && read_char == 'e'
            check_ident_or_keyword(TokenType::Boolean)
          else
            consume_ident
          end
        else
          consume_ident
        end
      when 'i'
        case read_char
        when 'f'
          check_ident_or_keyword(TokenType::Keyword)
        else
          consume_ident
        end
      when 'l'
        case read_char
        when 'e'
          case read_char
          when 't'
            check_ident_or_keyword(TokenType::Keyword)
          else
            consume_ident
          end
        when 'o'
          if read_char == 'o' && read_char == 'p'
            check_ident_or_keyword(TokenType::Keyword)
          else
            consume_ident
          end
        else
          consume_ident
        end
      when 'n'
        if read_char == 'u' && read_char == 'l' && read_char == 'l'
          check_ident_or_keyword(TokenType::Null)
        else
          consume_ident
        end
      when 'N'
        if read_char == 'A' && read_char == 'N'
          check_ident_or_keyword(TokenType::NAN)
        else
          consume_ident
        end
      when 'p'
        case read_char
        when 'r'
          case read_char
          when 'o'
            if read_char == 'p' && read_char == 'e' && read_char == 'r' && read_char == 't' && read_char == 'y'
              check_ident_or_keyword(TokenType::Keyword)
            else
              consume_ident
            end
          when 'i'
            if read_char == 'm' && read_char == 'i' && read_char == 't' && read_char == 'i' && read_char == 'v' && read_char == 'e'
              check_ident_or_keyword(TokenType::Keyword)
            else
              consume_ident
            end
          else
            consume_ident
          end
        else
          consume_ident
        end
      when 'r'
        if read_char == 'e' && read_char == 't' && read_char == 'u' && read_char == 'r' && read_char == 'n'
          check_ident_or_keyword(TokenType::Keyword)
        else
          consume_ident
        end
      when 't'
        case read_char
        when 'h'
          if read_char == 'r' && read_char == 'o' && read_char == 'w'
            check_ident_or_keyword(TokenType::Keyword)
          else
            consume_ident
          end
        when 'r'
          case read_char
          when 'u'
            case read_char
            when 'e'
              check_ident_or_keyword(TokenType::Boolean)
            else
              consume_ident
            end
          when 'y'
            check_ident_or_keyword(TokenType::Keyword)
          else
            consume_ident
          end
        when 'y'
          if read_char == 'p' && read_char == 'e' && read_char == 'o' && read_char == 'f'
            check_ident_or_keyword(TokenType::Keyword)
          else
            consume_ident
          end
        else
          consume_ident
        end
      when 'w'
        if read_char == 'h' && read_char == 'i' && read_char == 'l' && read_char == 'e'
          check_ident_or_keyword(TokenType::Keyword)
        else
          consume_ident
        end
      when 's'
        case read_char
        when 't'
          if read_char == 'a' && read_char == 't' && read_char == 'i' && read_char == 'c'
            check_ident_or_keyword(TokenType::Keyword)
          else
            consume_ident
          end
        when 'w'
          if read_char == 'i' && read_char == 't' && read_char == 'c' && read_char == 'h'
            check_ident_or_keyword(TokenType::Keyword)
          else
            consume_ident
          end
        else
          consume_ident
        end
      when '_'
        case read_char
        when '_'
          case read_char
          when 'F'
            if read_char == 'I' && read_char == 'L' && read_char == 'E' && read_char == '_' && read_char == '_'
              if ident_start(read_char)
                consume_ident
              else
                @token.type = TokenType::String
                @token.value = File.basename @filename
              end
            else
              consume_ident
            end
          when 'D'
            if read_char == 'I' && read_char == 'R' && read_char == '_' && read_char == '_'
              if ident_start(read_char)
                consume_ident
              else
                @token.type = TokenType::String
                @token.value = File.dirname @filename
              end
            else
              consume_ident
            end
          when 'L'
            if read_char == 'I' && read_char == 'N' && read_char == 'E' && read_char == '_' && read_char == '_'
              if ident_part(read_char)
                consume_ident
              else
                @token.type = TokenType::Numeric
                @token.value = "#{@row + 1}"
              end
            else
              consume_ident
            end
          else
            consume_ident
          end
        else
          consume_ident
        end
      when 'u'
        case read_char
        when 'n'
          case read_char
          when 'l'
            if read_char == 'e' && read_char == 's' && read_char == 's'
              check_ident_or_keyword(TokenType::Keyword)
            else
              consume_ident
            end
          when 't'
            if read_char == 'i' && read_char == 'l'
              check_ident_or_keyword(TokenType::Keyword)
            else
              consume_ident
            end
          else
            consume_ident
          end
        else
          consume_ident
        end
      when 'g'
        if read_char == 'u' && read_char == 'a' && read_char == 'r' && read_char == 'd'
          check_ident_or_keyword(TokenType::Keyword)
        else
          consume_ident
        end
      else
        if ident_start(current_char)
          consume_ident
        else
          unexpected_char
        end
      end

      @token.raw = @reader.frame.to_s[0..-2]
      @token.location.length = @token.raw.size

      @reader.reset
      @reader.frame << current_char

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
        when .number?
          # Nothing to do
        when '_'
          has_underscore = true
        else
          break
        end
      end

      if current_char == '.' && peek_char.number?
        read_char
        loop do
          case read_char
          when .number?
            # Nothing to do
          when '_'
            has_underscore = true
          else
            break
          end
        end
      end

      number_value = @reader.frame.to_s[0..-2]

      if has_underscore
        number_value = number_value.tr("_", "")
      end

      @token.value = number_value
    end

    # Consume a string literal
    def consume_string(initial_row, initial_column, initial_pos)
      @token.type = TokenType::String
      io = IO::Memory.new

      loop do
        case char = read_char
        when '\\'
          case char = read_char
          when 'b'
            io << "\u{8}"
          when 'n'
            io << "\n"
          when 'r'
            io << "\r"
          when 't'
            io << "\t"
          when 'v'
            io << "\v"
          when 'f'
            io << "\f"
          when 'e'
            io << "\e"
          when '\n'
            io << "\n"
          when '"'
            io << "\""
          when '\\'
            io << "\\"
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
        else
          io << char
        end
      end

      @token.value = io.to_s
      io.clear
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

      @token.value = @reader.frame.to_s[0..-2]
    end

    def consume_multiline_comment
      @token.type = TokenType::Comment

      loop do
        case read_char
        when '*'
          case read_char
          when '/'
            read_char # Advance one more position
            break
          else
            # Nothing to do
          end
        else
          # Nothing to do
        end
      end

      @token.value = @reader.frame.to_s[0..-2]
    end

    # Consume an identifier
    def consume_ident
      while ident_part(current_char)
        read_char
      end

      @token.type = TokenType::Identifier
      @token.value = @reader.frame.to_s[0..-2]
    end

    # Returns true if *char* could be the start of an identifier
    def ident_start(char : Char)
      char.letter? || char == '_' || char == '$' || char.ord > 0x9F
    end

    # Returns true if *char* could be inside an identifier
    def ident_part(char : Char)
      ident_start(char) || char.number? || char == '$'
    end

    # Checks if the current buffer is a keyword of an identifier
    def check_ident_or_keyword(symbol)
      if ident_part(peek_char)
        read_char
        consume_ident
      else
        read_char
        @token.type = symbol
        @token.value = @reader.frame.to_s[0..-2]
      end
    end

    # Called when an unexpected char was read
    def unexpected_char
      # Create a location
      loc = Location.new
      loc.filename = @filename
      loc.pos = @reader.pos - 1
      loc.row = @row
      loc.column = @column
      loc.length = 1

      char = current_char
      raise SyntaxError.new(loc, "Unexpected '#{char}'")
    end
  end
end
