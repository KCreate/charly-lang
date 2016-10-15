require "./token.cr"
require "../../file.cr"

class Lexer
  property tokens : Array(Token)
  property input : VirtualFile
  property reader : Char::Reader
  property token : Token

  def initialize(input)
    @input = input
    @token = Token.new
    @tokens = [] of Token
    @reader = Char::Reader.new @input.content
  end

  # Get the current_char
  def current_char
    @reader.current_char
  end

  # Get the next char
  def next_char
    @reader.next_char
  end

  # Go to the next char and set the token type
  def next_char(type)
    @token.type = type
    next_char
  end

  # Peek the next char
  def peek_char
    @reader.peek_next_char
  end

  # Resets the current token list and the current token
  def reset_token
    @token.type = TokenType::Unknown
    @token.value = ""
    @token.raw = ""
  end

  # Returns the contents of @reader.string
  # starting at *start* and stopping at @reader.pos - 1
  def string_range(start)
    @reader.string.byte_slice(start, @reader.pos - start)
  end

  # Return all tokens in a string
  def all_tokens

    # Read as many tokens as we can
    while next_token.is_a? Token
      @tokens << @token.dup

      # Break if we reached the end of the file
      if @token.type == TokenType::EOF
        break
      end
    end

    @tokens
  end

  # Return the next token in the file
  def next_token
    reset_token
    start = @reader.pos

    case current_char
    when ' ', '\t'
      consume_whitespace
    when '\n'
      consume_newline
    when ';'
      next_char TokenType::Semicolon
    when ','
      next_char TokenType::Comma
    when '.'
      next_char TokenType::Point
    when '"'
      consume_string(start)
    when '0'..'9'
      consume_numeric(start)
    when '+'
      next_char TokenType::Plus
    when '-'
      next_char TokenType::Minus
    when '/'
      next_char TokenType::Divd
    when '*'
      case peek_char
      when '*'
        next_char
        next_char TokenType::Pow
      else
        next_char TokenType::Mult
      end
    when '%'
      next_char TokenType::Mod
    when '='
      case peek_char
      when '='
        next_char
        next_char TokenType::Equal
      else
        next_char TokenType::Assignment
      end
    when '!'
      next_char TokenType::Not
    when '<'
      case peek_char
      when '='
        next_char
        next_char TokenType::LessEqual
      else
        next_char TokenType::Less
      end
    when '>'
      case peek_char
      when '='
        next_char
        next_char TokenType::GreaterEqual
      else
        next_char TokenType::Greater
      end
    when '('
      next_char TokenType::LeftParen
    when ')'
      next_char TokenType::RightParen
    when '{'
      next_char TokenType::LeftCurly
    when '}'
      next_char TokenType::RightCurly
    when '['
      next_char TokenType::LeftBracket
    when ']'
      next_char TokenType::RightBracket
    when '\0'
      @token.type = TokenType::EOF
    when 'c'
      case next_char
      when 'l'
        case next_char
        when 'a'
          case next_char
          when 's'
            case next_char
            when 's'
              check_ident_or_keyword(TokenType::Keyword, start)
            else
              consume_ident(start)
            end
          else
            consume_ident(start)
          end
        else
          consume_ident(start)
        end
      when 'o'
        case next_char
        when 'n'
          case next_char
          when 's'
            case next_char
            when 't'
              check_ident_or_keyword(TokenType::Keyword, start)
            else
              consume_ident(start)
            end
          else
            consume_ident(start)
          end
        else
          consume_ident(start)
        end
      else
        consume_ident(start)
      end
    when 'e'
      case next_char
      when 'l'
        case next_char
        when 's'
          case next_char
          when 'e'
            check_ident_or_keyword(TokenType::Keyword, start)
          else
            consume_ident(start)
          end
        else
          consume_ident(start)
        end
      else
        consume_ident(start)
      end
    when 'f'
      case next_char
      when 'u'
        case next_char
        when 'n'
          case next_char
          when 'c'
            check_ident_or_keyword(TokenType::Keyword, start)
          else
            consume_ident(start)
          end
        else
          consume_ident(start)
        end
      when 'a'
        case next_char
        when 'l'
          case next_char
          when 's'
            case next_char
            when 'e'
              check_ident_or_keyword(TokenType::Boolean, start)
            else
              consume_ident(start)
            end
          else
            consume_ident(start)
          end
        else
          consume_ident(start)
        end
      else
        consume_ident(start)
      end
    when 'i'
      case next_char
      when 'f'
        check_ident_or_keyword(TokenType::Keyword, start)
      else
        consume_ident(start)
      end
    when 'l'
      case next_char
      when 'e'
        case next_char
        when 't'
          check_ident_or_keyword(TokenType::Keyword, start)
        else
          consume_ident(start)
        end
      else
        consume_ident(start)
      end
    when 'n'
      case next_char
      when 'u'
        case next_char
        when 'l'
          case next_char
          when 'l'
            check_ident_or_keyword(TokenType::Null, start)
          else
            consume_ident(start)
          end
        else
          consume_ident(start)
        end
      else
        consume_ident(start)
      end
    when 't'
      case next_char
      when 'r'
        case next_char
        when 'u'
          case next_char
          when 'e'
            check_ident_or_keyword(TokenType::Boolean, start)
          else
            consume_ident(start)
          end
        else
          consume_ident(start)
        end
      else
        consume_ident(start)
      end
    when 'w'
      case next_char
      when 'h'
        case next_char
        when 'i'
          case next_char
          when 'l'
            case next_char
            when 'e'
              check_ident_or_keyword(TokenType::Keyword, start)
            else
              consume_ident(start)
            end
          else
            consume_ident(start)
          end
        else
          consume_ident(start)
        end
      else
        consume_ident(start)
      end
    when '#'
      consume_comment(start)
    else
      if ident_start(current_char)
        consume_ident(start)
      else
        unknown_token
      end
    end

    @token.raw = string_range(start)
    @token
  end

  # Consumes whitespaces (space and tabs)
  def consume_whitespace
    @token.type = TokenType::Whitespace
    start = @reader.pos

    # Read as many whitespaces as possible
    while true
      char = next_char
      case char
      when ' ', '\t'
        # Nothing to do
      when '\\'
        if next_char == '\n'
          next_char
        else
          unknown_token
        end
      else
        break
      end
    end

    @token.value = string_range(start)
  end

  # Consumes newlines
  def consume_newline
    @token.type = TokenType::Newline
    start = @reader.pos

    while true
      char = next_char
      case char
      when '\n'
        # Nothing to do
      else
        break
      end
    end
  end

  # Consumes Integer and Float values
  def consume_numeric(start)
    @token.type = TokenType::Numeric
    has_underscore = false
    is_float = false

    while true
      case next_char
      when .digit?
        # Nothing to do
      when '_'
        has_underscore = true
      else
        break
      end
    end

    if current_char == '.' && peek_char.digit?
      next_char
      while true
        case next_char
        when .digit?
          # Nothing to do
        when '_'
          has_underscore = true
        else
          break
        end
      end
    end

    number_value = string_range(start)

    if has_underscore
      number_value = number_value.tr("_", "")
    end
    @token.value = number_value
  end

  # Consume a string literal
  def consume_string(start)
    start = start + 1
    io = MemoryIO.new
    while true
      char = next_char
      case char
      when '\\'
        char = next_char
        case char
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
        when '\0'
          raise "Unterminated quoted string"
        end
      when '"'
        break
      when '\0'
        raise "Unterminated quoted string"
      else
        io << char
      end
    end
    @token.type = TokenType::String
    @token.value = io.to_s
    next_char
  end

  # Consumes a comment
  def consume_comment(start)
    while current_char != '\n'
      next_char
    end
    @token.type = TokenType::Comment
    @token.value = string_range(start)
  end

  # Starts consuming an identifier
  def consume_ident(start)
    while ident_part(current_char)
      next_char
    end
    @token.type = TokenType::Identifier
    @token.value = string_range(start)
  end

  # Returns true if *char* could be the start of an identifier
  def ident_start(char)
    char.alpha? || char == '_' || char.ord > 0x9F
  end

  # Returns true if *char* could be inside an identifier
  def ident_part(char)
    ident_start(char) || char.digit?
  end

  # Checks if the current buffer is a keyword or an identifier
  def check_ident_or_keyword(symbol, start)
    if ident_part(peek_char)
      consume_ident(start)
    else
      next_char
      @token.type = symbol
      @token.value = string_range(start)
    end
  end

  # Called when a unknown token is received
  def unknown_token
    raise "Unknown token: #{current_char.inspect}"
  end
end
