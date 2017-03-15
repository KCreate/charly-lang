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
      TokenType::Comment,
    }

    # Some properties to make the parser context aware
    property return_allowed : Bool
    property break_allowed : Bool
    property continue_allowed : Bool

    # Create a Program from *source* called *filename*
    def self.create(source : IO, filename : String)
      parser = Parser.new(source, filename)
      return parser.parse
    end

    # Creates a program from *source* located inside the virtual directory *basedirectory*
    def self.create(source : String, basedirectory : String)
      self.create(IO::Memory.new(source), basedirectory + "/VM-#{Time.now.epoch}")
    end

    # Creates a program from *source* called *filename*
    def initialize(source : IO, @filename : String)
      super

      # We immediately consume the first token
      advance

      @return_allowed = false
      @break_allowed = false
      @continue_allowed = false
    end

    # Parses a program
    def parse
      tree = parse_program
      program = Program.new(@filename, tree, @tokens)
      @reader.clear
      program
    end

    # Advance to the next token, skipping any tokens we don't care about
    private def advance
      while SKIP_TOKENS.includes? read_token.type
      end
      @token
    end

    private def advance_to_token(type : TokenType)
      token_char = [] of TokenType
      until @token.type == type && token_char.size == 0
        case @token.type
        when TokenType::LeftCurly
          token_char << @token.type
        when TokenType::LeftParen
          token_char << @token.type
        when TokenType::LeftBracket
          token_char << @token.type
        when TokenType::RightCurly
          if token_char.last == TokenType::LeftCurly
            token_char.pop
          else
            unexpected_token @token.type
          end
        when TokenType::RightParen
          if token_char.last == TokenType::LeftParen
            token_char.pop
          else
            unexpected_token @token.type
          end
        when TokenType::RightBracket
          if token_char.last == TokenType::LeftBracket
            token_char.pop
          else
            unexpected_token @token.type
          end
        end

        advance
      end
    end

    # :nodoc:
    private def unexpected_token(expected : TokenType? = nil, value : String? = nil)
      unless @token.type == TokenType::EOF
        if expected && value
          error_message = "Expected #{value}, got #{@token.type}"
        elsif expected
          error_message = "Expected #{expected}, got #{@token.type}"
        else
          error_message = "Unexpected #{@token.type}"
        end
      else
        if value
          error_message = "Unexpected end of file, expected #{value}"
        elsif expected
          error_message = "Unexpected end of file, expected #{expected}"
        else
          error_message = "Unexpected end of file"
        end
      end

      raise SyntaxError.new(@token.location, error_message)
    end

    # :nodoc:
    private def unallowed_token
      error_message = "You are not allowed to use #{@token.value} at this location"

      raise SyntaxError.new(@token.location, error_message)
    end

    # :nodoc:
    private def assert_token(type : TokenType)
      unless @token.type == type
        unexpected_token type
      end

      yield
    end

    # :nodoc:
    private def assert_token(type : TokenType, value : String)
      unless @token.type == type && @token.value == value
        unexpected_token type, value
      end

      yield
    end

    # :nodoc:
    private def expect(type : TokenType)
      unless @token.type == type
        unexpected_token type
      end

      advance
    end

    # :nodoc:
    private def expect(type : TokenType, value : String)
      unless @token.type == type && @token.value == value
        unexpected_token type, value
      end

      advance
    end

    # :nodoc:
    private def skip(type : TokenType)
      advance if @token.type == type
    end

    # :nodoc:
    private def skip(type : TokenType, value : String)
      advance if @token.type == type && @token.value == value
    end

    # :nodoc:
    private def if_token(type : TokenType)
      yield if @token.type == type
    end

    # :nodoc:
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

    private def parse_class_block
      start_location = nil
      end_location = nil

      assert_token TokenType::LeftCurly do
        start_location = @token.location
        advance
      end

      body = parse_class_body

      assert_token TokenType::RightCurly do
        end_location = @token.location
        advance
      end

      body.at(start_location, end_location)
    end

    private def parse_switch_block
      start_location = nil
      end_location = nil

      assert_token TokenType::LeftCurly do
        start_location = @token.location
        advance
      end

      nodes, default_block = parse_switch_body

      assert_token TokenType::RightCurly do
        end_location = @token.location
        advance
      end

      return { nodes, default_block, end_location }
    end

    private def parse_switch_body
      nodes = [] of SwitchNode
      default_block : Block? = nil

      start_location = @token.location

      until @token.type == TokenType::RightCurly
        case @token.type
        when TokenType::Keyword
          case @token.value
          when "case"
            start_location = @token.location
            advance

            values : ExpressionList
            block : Block

            case @token.type
            when TokenType::LeftParen
              advance
              values = parse_expression_list TokenType::RightParen
              expect TokenType::RightParen
            else
              values = parse_expression_list TokenType::RightParen
            end

            case @token.type
            when TokenType::LeftCurly
              block = parse_block
            else
              exp = parse_expression
              block = Block.new([exp] of ASTNode).at(exp)
            end

            end_location = block.location_end
            nodes << SwitchNode.new(values, block).at(start_location, block.location_end)
          when "default"
            start_location = @token.location
            advance

            body = parse_block
            default_block = body.at(start_location, body.location_end)

            end_location = body.location_end
          else
            unallowed_token
          end
        else
          unexpected_token value: "case or default statement"
        end
      end

      return {
        SwitchNodeList.new(nodes).at(start_location, end_location),
        default_block
      }
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

    # Parses the body of a class
    private def parse_class_body
      exps = [] of ASTNode

      until @token.type == TokenType::RightCurly
        exps << parse_class_statement
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

              if value.is_a?(FunctionLiteral) && value.name.size == 0
                value.name = identifier.name
              end

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
        when "until"
          return parse_until_statement
        when "unless"
          return parse_unless_statement
        when "guard"
          return parse_guard_statement
        when "loop"
          return parse_loop_statement
        when "return"
          unless @return_allowed
            unallowed_token
          end

          advance

          return_value = NullLiteral.new.at(start_location)
          end_location = start_location

          unless @token.type == TokenType::Semicolon ||
                 @token.type == TokenType::RightCurly ||
                 @token.type == TokenType::EOF
            return_value = parse_expression
            end_location = return_value.location_end
          end

          advance_to_token TokenType::RightCurly
          return ReturnStatement.new(return_value).at(start_location, end_location)
        when "break"
          unless @break_allowed
            unallowed_token
          end

          advance
          end_location = start_location
          skip TokenType::Semicolon
          advance_to_token TokenType::RightCurly
          return BreakStatement.new.at(start_location, end_location)
        when "continue"
          unless @continue_allowed
            unallowed_token
          end

          advance
          end_location = start_location
          skip TokenType::Semicolon
          advance_to_token TokenType::RightCurly
          return ContinueStatement.new.at(start_location, end_location)
        when "throw"
          advance
          value = parse_expression
          end_location = value.location_end
          skip TokenType::Semicolon
          return ThrowStatement.new(value).at(start_location, end_location)
        when "func", "class", "primitive"
          node = parse_expression

          if node.is_a?(FunctionLiteral)
            if node.name.size > 0
              node = VariableInitialisation.new(
                IdentifierLiteral.new(node.name).at(node),
                node
              ).at(node)
            end
          end

          if node.is_a? ClassLiteral
            node = VariableInitialisation.new(
              IdentifierLiteral.new(node.name).at(node),
              node
            ).at(node)
          end

          if node.is_a? PrimitiveClassLiteral
            node = VariableInitialisation.new(
              IdentifierLiteral.new(node.name).at(node),
              node
            ).at(node)
          end

          skip TokenType::Semicolon
          return node
        when "switch"
          return parse_switch_statement
        when "typeof"
          return parse_typeof
        end
      else
        expression = parse_expression
        skip TokenType::Semicolon
        return expression
      end

      unexpected_token value: "Statement"
    end

    private def parse_class_statement
      start_location = @token.location

      case @token.type
      when TokenType::Keyword
        case @token.value
        when "property"
          advance

          identifier = IdentifierLiteral.new("-")
          assert_token TokenType::Identifier do
            identifier = IdentifierLiteral.new(@token.value).at(@token.location)
            advance
          end

          if_token TokenType::Semicolon do
            advance
          end

          return PropertyDeclaration.new(identifier).at(start_location, identifier.location_end)
        when "func"
          value = parse_func_literal

          unless value.name.size > 0
            raise SyntaxError.new(value, "Missing function name")
          end

          if_token TokenType::Semicolon do
            advance
          end

          return value
        when "static"
          advance

          value = parse_class_statement

          return StaticDeclaration.new(value).at(start_location, value.location_end)
        end
      end

      unexpected_token TokenType::Keyword, "property"
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

      alternate = nil
      if_token TokenType::Keyword, "else" do
        advance

        case @token.type
        when TokenType::Keyword
          assert_token TokenType::Keyword, "if" do
            alternate = parse_if_statement
          end
        else
          alternate = parse_block
        end
      end

      if alternate
        end_location = alternate.location_end
      else
        end_location = consequent.location_end
      end

      return IfStatement.new(test, consequent, alternate).at(start_location, end_location)
    end

    private def parse_switch_statement
      start_location = @token.location
      expect TokenType::Keyword, "switch"

      case @token.type
      when TokenType::LeftParen
        advance
        test = parse_expression
        expect TokenType::RightParen
      else
        test = parse_expression
      end

      backup_break_allowed = @break_allowed
      @break_allowed = true
      nodes, default_block, end_location = parse_switch_block
      @break_allowed = backup_break_allowed

      if end_location.is_a? Location
        statement = SwitchStatement.new(test, nodes, default_block).at(start_location, end_location)
      else
        statement = SwitchStatement.new(test, nodes, default_block).at(start_location)
      end

      return statement
    end

    private def parse_guard_statement
      start_location = @token.location
      expect TokenType::Keyword, "guard"

      case @token.type
      when TokenType::LeftParen
        advance
        test = parse_expression
        expect TokenType::RightParen
      else
        test = parse_expression
      end

      alternate = parse_block

      return GuardStatement.new(test, alternate).at(start_location, alternate.location_end)
    end

    private def parse_unless_statement
      start_location = @token.location
      expect TokenType::Keyword, "unless"

      case @token.type
      when TokenType::LeftParen
        advance
        test = parse_expression
        expect TokenType::RightParen
      else
        test = parse_expression
      end

      consequent = parse_block

      alternate = nil
      if_token TokenType::Keyword, "else" do
        advance
        alternate = parse_block
      end

      if alternate
        end_location = alternate.location_end
      else
        end_location = consequent.location_end
      end

      return UnlessStatement.new(test, consequent, alternate).at(start_location, end_location)
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

      backup_break_allowed = @break_allowed
      backup_continue_allowed = @continue_allowed
      @break_allowed = true
      @continue_allowed = true
      consequent = parse_block
      @break_allowed = backup_break_allowed
      @continue_allowed = backup_continue_allowed
      return WhileStatement.new(test, consequent).at(start_location, consequent.location_end)
    end

    private def parse_until_statement
      start_location = @token.location
      expect TokenType::Keyword, "until"

      case @token.type
      when TokenType::LeftParen
        advance
        test = parse_expression
        expect TokenType::RightParen
      else
        test = parse_expression
      end

      backup_break_allowed = @break_allowed
      backup_continue_allowed = @continue_allowed
      @break_allowed = true
      @continue_allowed = true
      consequent = parse_block
      @break_allowed = backup_break_allowed
      @continue_allowed = backup_continue_allowed
      return UntilStatement.new(test, consequent).at(start_location, consequent.location_end)
    end

    private def parse_loop_statement
      start_location = @token.location
      expect TokenType::Keyword, "loop"

      backup_break_allowed = @break_allowed
      backup_continue_allowed = @continue_allowed
      @break_allowed = true
      @continue_allowed = true
      consequent = parse_block
      @break_allowed = backup_break_allowed
      @continue_allowed = backup_continue_allowed
      return LoopStatement.new(consequent).at(start_location, consequent.location_end)
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
              left = ({{node.id}}).at(left, right)
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
      left = parse_ternary_if
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

          if operator.and_operator?
            left = VariableAssignment.new(left,
              BinaryExpression.new(operator.and_real_operator, left, right).at(left, right)
            ).at(left, right)
          else
            left = VariableAssignment.new(left, right).at(left, right)
          end
        else
          return left
        end
      end
    end

    private def parse_ternary_if
      condition = parse_logical_or
      case @token.type
      when TokenType::QuestionMark
        advance
        left = parse_ternary_if
        expect TokenType::Colon
        right = parse_ternary_if

        # Wrap the elements in blocks as required by the IfStatement
        left_block = Block.new([] of ASTNode).at(left)
        left_block.children << left

        right_block = right

        unless right.is_a? IfStatement
          right_block = Block.new([] of ASTNode).at(right)
          right_block.children << right
        end

        return IfStatement.new(condition, left_block, right_block).at(condition, right)
      else
        return condition
      end
    end

    parse_operator :logical_or, :logical_and, "Or.new left, right", "OR"
    parse_operator :logical_and, :bitwise_or, "And.new left, right", "AND"
    parse_operator :bitwise_or, :bitwise_xor, "BinaryExpression.new operator, left, right", "BitOR"
    parse_operator :bitwise_xor, :bitwise_and, "BinaryExpression.new operator, left, right", "BitXOR"
    parse_operator :bitwise_and, :equal_not, "BinaryExpression.new operator, left, right", "BitAND"
    parse_operator :equal_not, :less_greater, "ComparisonExpression.new operator, left, right", "Equal", "Not"
    parse_operator :less_greater, :bitwise_shift, "ComparisonExpression.new operator, left, right", "Less", "Greater", "LessEqual", "GreaterEqual"
    parse_operator :bitwise_shift, :add_sub, "BinaryExpression.new operator, left, right", "LeftShift", "RightShift"
    parse_operator :add_sub, :mult_div, "BinaryExpression.new operator, left, right", "Plus", "Minus"
    parse_operator :mult_div, :mod, "BinaryExpression.new operator, left, right", "Mult", "Divd"
    parse_operator :mod, :unary_expression, "BinaryExpression.new operator, left, right", "Mod"

    private def parse_unary_expression
      start_location = @token.location
      case operator = @token.type
      when TokenType::Plus, TokenType::Minus, TokenType::Not, TokenType::BitNOT
        advance
        value = parse_unary_expression
        return UnaryExpression.new(operator, value).at(start_location, value.location_end)
      else
        parse_pow
      end
    end

    private def parse_pow
      left = parse_typeof
      while true
        case @token.type
        when TokenType::Pow
          operator = @token.type
          advance
          right = parse_pow
          left = BinaryExpression.new(operator, left, right).at(left, right)
        else
          return left
        end
      end
    end

    private def parse_typeof
      start = @token.location
      if @token.type == TokenType::Keyword && @token.value == "typeof"
        advance
        right = parse_pow
        return TypeofExpression.new(right).at(start, right.location_end)
      else
        parse_call_expression
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

          arg = parse_expression

          end_location = @token.location
          expect TokenType::RightBracket
          identifier = IndexExpression.new(identifier, arg).at(identifier.location_start, end_location)
        when TokenType::Point
          advance

          member = Empty.new
          assert_token TokenType::Identifier do
            member = IdentifierLiteral.new(@token.value).at(@token.location)
            advance
          end

          if member.is_a? IdentifierLiteral
            identifier = MemberExpression.new(identifier, member).at(identifier, member)
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
        node = BooleanLiteral.new(@token.value == "true").at(@token.location)
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
      when TokenType::RightArrow
        node = parse_arrow_function
      when TokenType::Keyword
        case @token.value
        when "func"
          node = parse_func_literal
        when "class"
          node = parse_class_literal
        when "primitive"
          start_location = @token.location
          advance
          class_literal = parse_class_literal

          node = PrimitiveClassLiteral.new(
            class_literal.name,
            class_literal.block
          ).at(start_location, class_literal.location_end)
        when "switch"
          node = parse_switch_statement
        else
          unexpected_token TokenType::Keyword, "func"
        end
      else
        unexpected_token value: "an expression"
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
          exps << IdentifierLiteral.new(@token.value).at(@token.location)
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
      backup_return_allowed = @return_allowed
      backup_break_allowed = @break_allowed
      backup_continue_allowed = @continue_allowed
      @return_allowed = false
      @break_allowed = false
      @continue_allowed = false
      block = parse_block
      @return_allowed = backup_return_allowed
      @break_allowed = backup_break_allowed
      @continue_allowed = backup_continue_allowed
      return ContainerLiteral.new(block).at(block)
    end

    private def parse_func_literal
      start_location = @token.location
      expect TokenType::Keyword, "func"

      identifier = Empty.new

      case @token.type
      when TokenType::Identifier
        identifier = IdentifierLiteral.new(@token.value).at(@token.location)
        advance
      end

      arguments = IdentifierList.new([] of ASTNode)

      if_token TokenType::LeftParen do
        advance
        arguments = parse_identifier_list(TokenType::RightParen)
        expect TokenType::RightParen
      end

      backup_return_allowed = @return_allowed
      backup_break_allowed = @break_allowed
      backup_continue_allowed = @continue_allowed
      @return_allowed = true
      @break_allowed = false
      @continue_allowed = false
      block = parse_block
      @return_allowed = backup_return_allowed
      @break_allowed = backup_break_allowed
      @continue_allowed = backup_continue_allowed

      if identifier.is_a? IdentifierLiteral
        FunctionLiteral.new(identifier.name, arguments, block).at(start_location, block.location_end)
      else
        FunctionLiteral.new("", arguments, block).at(start_location, block.location_end)
      end
    end

    private def parse_arrow_function
      start_location = @token.location
      expect TokenType::RightArrow

      argumentlist = IdentifierList.new([] of ASTNode).at(start_location)
      block = Block.new([] of ASTNode)

      # Parse a possible argumentlist
      if_token TokenType::LeftParen do
        advance
        argumentlist = parse_identifier_list(TokenType::RightParen)
        expect TokenType::RightParen
      end

      case @token.type
      when TokenType::LeftCurly
        backup_return_allowed = @return_allowed
        backup_break_allowed = @break_allowed
        backup_continue_allowed = @continue_allowed
        @return_allowed = true
        @break_allowed = false
        @continue_allowed = false
        block = parse_block
        @return_allowed = backup_return_allowed
        @break_allowed = backup_break_allowed
        @continue_allowed = backup_continue_allowed
      else
        expression = parse_expression
        block.children << expression
        block.at(expression)
      end

      return FunctionLiteral.new("", argumentlist, block).at(start_location, block.location_end)
    end

    private def parse_class_literal
      start_location = @token.location
      expect TokenType::Keyword, "class"

      identifier = ""
      parents = IdentifierList.new([] of ASTNode)
      assert_token TokenType::Identifier do
        identifier = @token.value
        advance
      end

      if_token TokenType::Keyword, "extends" do
        advance

        if @token.type == TokenType::LeftCurly
          unexpected_token TokenType::Identifier
        end

        parents = parse_identifier_list(TokenType::LeftCurly)
      end

      backup_return_allowed = @return_allowed
      backup_break_allowed = @break_allowed
      backup_continue_allowed = @continue_allowed
      @return_allowed = false
      @break_allowed = false
      @continue_allowed = false
      block = parse_class_block
      @return_allowed = backup_return_allowed
      @break_allowed = backup_break_allowed
      @continue_allowed = backup_continue_allowed

      ClassLiteral.new(identifier, block, parents).at(start_location, block.location_end)
    end
  end
end
