require "../exception.cr"
require "./lexer.cr"
require "./token.cr"
require "./ast.cr"
require "../program.cr"

module Charly

  # The `Parser` turns a list of tokens into a Parse Tree (AST)
  class Parser < Lexer
    include AST

    # Tokens we want to skip
    SKIP_TOKENS = {
      TokenType::Newline,
      TokenType::Whitespace,
      TokenType::Comment
    }

    # Mapping between the assignment operators and the actual operators
    OPERATOR_MAPPING = {
      TokenType::PlusAssignment => TokenType::Plus,
      TokenType::MinusAssignment => TokenType::Minus,
      TokenType::MultAssignment => TokenType::Mult,
      TokenType::DivdAssignment => TokenType::Divd,
      TokenType::ModAssignment => TokenType::Mod,
      TokenType::PowAssignment => TokenType::Pow
    }

    # Create a Program from *source* called *filename*
    def self.create(source : IO, filename : String)
      parser = Parser.new(source, filename)
      return parser.parse
    end

    # Creates a program from *source* located inside the virtual directory *basedirectory*
    def self.create(source : String, basedirectory : String)
      self.create(MemoryIO.new(source), basedirectory + "/VM-#{Time.now.epoch}")
    end

    # Creates a program from *source* called *filename*
    def initialize(source : IO, @filename : String)
      super

      # We immediately consume the first token
      advance
    end

    # Parses a program and resets the @file_buffer afterwards
    def parse
      tree = parse_program
      Program.new(@filename, tree, @reader.finish.buffer.to_s)
    end

    # Advance to the next token, skipping any tokens we don't care about
    @[AlwaysInline]
    private def advance
      while SKIP_TOKENS.includes? read_token.type
      end
      @token
    end

    # :nodoc:
    @[AlwaysInline]
    private def unexpected_token
      error_message = "Unexpected #{@token.type}"

      if @token.type == TokenType::EOF
        error_message = "Unexpected end of file"
      end

      raise SyntaxError.new(@token.location, @reader.finish.buffer.to_s, error_message)
    end

    # :nodoc:
    @[AlwaysInline]
    private def assert_token(type : TokenType)
      unless @token.type == type
        unexpected_token
      end

      yield
    end

    # :nodoc:
    @[AlwaysInline]
    private def assert_token(type : TokenType, value : String)
      unless @token.type == type && @token.value == value
        unexpected_token
      end

      yield
    end

    # :nodoc:
    @[AlwaysInline]
    private def expect(type : TokenType)
      unless @token.type == type
        unexpected_token
      end

      advance
    end

    # :nodoc:
    @[AlwaysInline]
    private def expect(type : TokenType, value : String)
      unless @token.type == type && @token.value == value
        unexpected_token
      end

      advance
    end

    # :nodoc:
    @[AlwaysInline]
    private def skip(type : TokenType)
      advance if @token.type == type
    end

    # :nodoc:
    @[AlwaysInline]
    private def skip(type : TokenType, value : String)
      advance if @token.type == type && @token.value == value
    end

    # :nodoc:
    @[AlwaysInline]
    private def if_token(type : TokenType)
      yield if @token.type == type
    end

    # :nodoc:
    @[AlwaysInline]
    private def if_token(type : TokenType, value : String)
      yield if @token.type == type && @token.value == value
    end

    # Parses a program
    private def parse_program
      parse_block_body false
    end

    # Parses a block
    private def parse_block
      start_location = nil
      end_location = nil

      assert_token TokenType::LeftCurly do
          start_location = @token.location
          advance
      end

      body = parse_block_body

      assert_token TokenType::RightCurly do
        end_location = @token.location
        advance
      end

      body.at(start_location, end_location)
    end

    # Parses the body of a block
    private def parse_block_body(stop_on_curly = true)
      exps = [] of ASTNode

      if stop_on_curly
        until @token.type == TokenType::RightCurly
          exps << parse_statement
        end
      else
        until @token.type == TokenType::EOF
          exps << parse_statement
        end
      end

      return Block.new(exps)
    end

    # Parses a statement
    private def parse_statement
      case @token.type
      when TokenType::Keyword
        start_location = @token.location

        case @token.value
        when "let"
          case advance.type
          when TokenType::Identifier
            identifier = IdentifierLiteral.new(@token.value).at(@token.location)
            ident_location = @token.location

            case advance.type
            when TokenType::Semicolon
              advance
              return VariableInitialisation.new(
                identifier,
                NullLiteral.new.at(start_location, ident_location)
              ).at(start_location, ident_location)
            when TokenType::Assignment
              advance
              value = parse_expression
              end_location = value.location_end
              skip TokenType::Semicolon
              return VariableInitialisation.new(identifier, value).at(start_location, end_location)
            else
              return VariableInitialisation.new(
                identifier,
                NullLiteral.new.at(start_location, ident_location)
              ).at(start_location)
            end
          end
        when "const"
          case advance.type
          when TokenType::Identifier
            identifier = IdentifierLiteral.new(@token.value).at(@token.location)
            advance
            expect TokenType::Assignment
            value = parse_expression
            end_location = value.location_end
            skip TokenType::Semicolon
            return ConstantInitialisation.new(identifier, value).at(start_location, end_location)
          end
        when "if"
          return parse_if_statement
        when "while"
          return parse_while_statement
        when "try"
          return parse_try_statement
        when "return"
          advance

          return_value = NullLiteral.new.at(start_location)
          end_location = start_location

          unless @token.type == TokenType::Semicolon ||
                 @token.type == TokenType::RightCurly ||
                 @token.type == TokenType::EOF
            return_value = parse_expression
            end_location = return_value.location_end
          end

          skip TokenType::Semicolon
          return ReturnStatement.new(return_value).at(start_location, end_location)
        when "break"
          advance
          end_location = start_location
          skip TokenType::Semicolon
          return BreakStatement.new.at(start_location, end_location)
        when "throw"
          advance
          value = parse_expression
          end_location = value.location_end
          skip TokenType::Semicolon
          return ThrowStatement.new(value).at(start_location, end_location)
        when "func", "class"
          node = parse_expression

          if node.is_a?(FunctionLiteral) || node.is_a?(ClassLiteral)
            if (name = node.name).is_a?(String)
              node = VariableInitialisation.new(
                IdentifierLiteral.new(name).at(node.location_start, node.location_end),
                node
              ).at(node.location_start, node.location_end)
            end
          end

          skip TokenType::Semicolon
          return node
        end
      else
        expression = parse_expression
        skip TokenType::Semicolon
        return expression
      end

      unexpected_token
    end

    private def parse_if_statement
      start_location = @token.location
      expect TokenType::Keyword, "if"

      case @token.type
      when TokenType::LeftParen
        advance
        test = parse_expression
        expect TokenType::RightParen
      else
        test = parse_expression
      end

      consequent = parse_block

      alternate = Empty.new.at(consequent.location_start, consequent.location_end)
      if_token TokenType::Keyword, "else" do
        advance

        case @token.type
        when TokenType::Keyword
          case @token.value
          when "if"
            alternate = parse_if_statement
          else
            unexpected_token
          end
        else
          alternate = parse_block
        end
      end

      node = IfStatement.new(test, consequent, alternate).at(start_location, alternate.location_end)
    end

    private def parse_while_statement
      start_location = @token.location
      expect TokenType::Keyword, "while"

      case @token.type
      when TokenType::LeftParen
        advance
        test = parse_expression
        expect TokenType::RightParen
      else
        test = parse_expression
      end

      consequent = parse_block
      return WhileStatement.new(test, consequent).at(start_location, consequent.location_end)
    end

    private def parse_try_statement
      start_location = @token.location
      expect TokenType::Keyword, "try"

      try_block = Empty.new
      exception_name = IdentifierLiteral.new("e")
      catch_block = Empty.new

      try_block = parse_block

      expect TokenType::Keyword, "catch"

      expect TokenType::LeftParen
      assert_token TokenType::Identifier do
        exception_name = IdentifierLiteral.new(@token.value).at(@token.location)
        advance
      end
      expect TokenType::RightParen

      catch_block = parse_block

      return TryCatchStatement.new(try_block, exception_name, catch_block).at(start_location, catch_block.location_end)
    end

    # Helper macro to prevent duplicate code for operator precedence parsing
    macro parse_operator(name, next_operator, node, *operators)
      private def parse_{{name.id}}
          left = parse_{{next_operator.id}}
          while true
            case @token.type
            when {{
                *operators.map { |field|
                  "TokenType::#{field.id}".id
                }
              }}
              operator = @token.type
              advance
              right = parse_{{next_operator.id}}
              left = ({{node.id}}).at(left.location_start, right.location_end)
            else
              return left
            end
          end
        end
    end

    # Parse an expression
    private def parse_expression
      return parse_assignment
    end

    private def parse_assignment
      left = parse_logical_and
      while true
        case @token.type
        when TokenType::Assignment,
              TokenType::PlusAssignment,
              TokenType::MinusAssignment,
              TokenType::MultAssignment,
              TokenType::DivdAssignment,
              TokenType::ModAssignment,
              TokenType::PowAssignment
          operator = @token.type
          advance
          right = parse_assignment

          if operator == TokenType::Assignment
            left = VariableAssignment.new(left, right).at(left.location_start, right.location_end)
          else
            left = VariableAssignment.new(left,
              BinaryExpression.new(OPERATOR_MAPPING[operator], left, right).at(left.location_start, right.location_end)
            ).at(left.location_start, right.location_end)
          end
        else
          return left
        end
      end
    end

    parse_operator :logical_and, :logical_or, "And.new left, right", "AND"
    parse_operator :logical_or, :equal_not, "Or.new left, right", "OR"
    parse_operator :equal_not, :less_greater, "ComparisonExpression.new operator, left, right", "Equal", "Not"
    parse_operator :less_greater, :add_sub, "ComparisonExpression.new operator, left, right", "Less", "Greater", "LessEqual", "GreaterEqual"
    parse_operator :add_sub, :mult_div, "BinaryExpression.new operator, left, right", "Plus", "Minus"
    parse_operator :mult_div, :mod, "BinaryExpression.new operator, left, right", "Mult", "Divd"
    parse_operator :mod, :unary_expression, "BinaryExpression.new operator, left, right", "Mod"

    private def parse_unary_expression
      start_location = @token.location
      case operator = @token.type
      when TokenType::Minus, TokenType::Not
        advance
        value = parse_unary_expression
        return UnaryExpression.new(operator, value).at(start_location, value.location_end)
      else
        parse_pow
      end
    end

    private def parse_pow
      left = parse_call_expression
      while true
        case @token.type
        when TokenType::Pow
          operator = @token.type
          advance
          right = parse_pow
          left = BinaryExpression.new(operator, left, right).at(left.location_start, right.location_end)
        else
          return left
        end
      end
    end

    private def parse_call_expression
      identifier = parse_literal
      while true
        case @token.type
        when TokenType::LeftParen
          advance

          args = parse_expression_list(TokenType::RightParen)
          end_location = @token.location
          expect TokenType::RightParen
          identifier = CallExpression.new(identifier, args).at(identifier.location_start, end_location)
        when TokenType::LeftBracket
          advance

          args = parse_expression_list(TokenType::RightBracket)

          end_location = @token.location
          expect TokenType::RightBracket
          identifier = IndexExpression.new(identifier, args).at(identifier.location_start, end_location)
        when TokenType::Point
          advance

          member = Empty.new
          assert_token TokenType::Identifier do
            member = IdentifierLiteral.new(@token.value).at(@token.location)
            advance
          end

          if member.is_a? IdentifierLiteral
            identifier = MemberExpression.new(identifier, member).at(identifier.location_start, member.location_end)
          end
        else
          return identifier
        end
      end
    end

    private def parse_literal
      case @token.type
      when TokenType::AtSign
        start_location = @token.location
        advance
        node = Empty.new
        assert_token TokenType::Identifier do
          node = MemberExpression.new(
            IdentifierLiteral.new("self").at(start_location),
            IdentifierLiteral.new(@token.value).at(@token.location)
          ).at(start_location, @token.location)
          advance
        end
      when TokenType::LeftParen
        advance
        node = parse_expression
        expect TokenType::RightParen
      when TokenType::Identifier
        node = IdentifierLiteral.new(@token.value).at(@token.location)
        advance
      when TokenType::Numeric
        node = NumericLiteral.new(@token.value.to_f64).at(@token.location)
        advance
      when TokenType::String
        node = StringLiteral.new(@token.value).at(@token.location)
        advance
      when TokenType::Boolean
        node = BooleanLiteral.new(@token.value[0] == 't').at(@token.location)
        advance
      when TokenType::Null
        node = NullLiteral.new.at(@token.location)
        advance
      when TokenType::NAN
        node = NANLiteral.new.at(@token.location)
        advance
      when TokenType::LeftBracket
        node = parse_array_literal
      when TokenType::LeftCurly
        node = parse_container_literal
      when TokenType::Keyword
        case @token.value
        when "func"
          node = parse_func_literal
        when "class"
          node = parse_class_literal
        else
          unexpected_token
        end
      else
        unexpected_token
      end

      return node
    end

    private def parse_expression_list(end_token : TokenType)
      exps = [] of ASTNode

      should_read = @token.type != end_token
      while should_read
        should_read = false

        exps << parse_expression

        if @token.type == TokenType::Comma
          should_read = true
          advance
        end
      end

      return ExpressionList.new(exps)
    end

    private def parse_identifier_list(end_token : TokenType)
      exps = [] of ASTNode

      should_read = @token.type != end_token
      while should_read
        should_read = false

        assert_token TokenType::Identifier do
          exps << IdentifierLiteral.new(@token.value)
          advance
        end

        if @token.type == TokenType::Comma
          should_read = true
          advance
        end
      end

      return IdentifierList.new(exps)
    end

    private def parse_array_literal
      start_location = @token.location

      expect TokenType::LeftBracket
      exps = parse_expression_list(TokenType::RightBracket)

      end_location = @token.location
      expect TokenType::RightBracket
      return ArrayLiteral.new(exps.children).at(start_location, end_location)
    end

    private def parse_container_literal
      block = parse_block
      return ContainerLiteral.new(block).at(block.location_start, block.location_end)
    end

    private def parse_func_literal
      start_location = @token.location
      expect TokenType::Keyword, "func"

      identifier = Empty.new
      if_token TokenType::Identifier do
        identifier = IdentifierLiteral.new(@token.value).at(@token.location)
        advance
      end

      expect TokenType::LeftParen
      arguments = parse_identifier_list(TokenType::RightParen)
      expect TokenType::RightParen

      block = parse_block

      if identifier.is_a? IdentifierLiteral
        FunctionLiteral.new(identifier.name, arguments, block).at(start_location, block.location_end)
      else
        FunctionLiteral.new(nil, arguments, block).at(start_location, block.location_end)
      end
    end

    private def parse_class_literal

      start_location = @token.location
      expect TokenType::Keyword, "class"

      identifier = Empty.new
      parents = IdentifierList.new
      if_token TokenType::Identifier do
        identifier = IdentifierLiteral.new(@token.value)
        advance
      end

      if_token TokenType::Less do
        advance

        if @token.type == TokenType::LeftCurly
          unexpected_token
        end

        parents = parse_identifier_list(TokenType::LeftCurly)
      end

      block = parse_block

      if identifier.is_a? IdentifierLiteral
        ClassLiteral.new(identifier.name, block, parents).at(start_location, block.location_end)
      else
        ClassLiteral.new(nil, block, parents).at(start_location, block.location_end)
      end
    end

  end
end
