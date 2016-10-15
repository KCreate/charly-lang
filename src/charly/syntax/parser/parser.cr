require "../ast/ast.cr"
require "../lexer/lexer.cr"
require "./structure.cr"
require "./linker.cr"

# Parses a list of tokens into a program
class Parser

  # A single production
  alias Prod = Proc(Bool)
  alias Production = Prod | Bool
  property tokens : Array(Token)
  property tree : Program
  property file : VirtualFile
  property node : ASTNode
  property next : UInt64
  property flags : Array(String)

  # Create a new parser from a virtualfile
  def initialize(@file, @flags)

    # Get all the tokens from the file
    lexer = Lexer.new file
    @tokens = lexer.all_tokens
    @next = 0_u64

    # Remove whitespace, newlines and comments from the tokens
    @tokens.select! do |token|
      token.type != TokenType::Whitespace &&
      token.type != TokenType::Newline &&
      token.type != TokenType::Comment
    end

    if flags.includes? "tokens"
      @tokens.each do |token|
        puts token
      end
    end

    # Initialize the tree
    @tree = Program.new nil
    @tree.file = file
    @node = @tree
  end

  # Begin parsing
  def parse

    # Every program is just the body of a block
    block_body

    # Check if the whole program was parsed
    if @next < @tokens.size - 1

      # Display the last 10 tokens that were touched by the parser
      @tokens.select { |token|
        token.touched
      }.last(20).each do |token|
        puts token
      end

      raise "Could not parse #{@file.filename}"
    end

    # Re-Structure the tree
    structure = Structure.new @tree
    structure.start

    # Link the tree
    linker = Linker.new @tree
    linker.start

    # If the *--ast* cli option was passed, display the tree
    if flags.includes? "ast"
      puts "--- AST: #{@file.filename} ---"
      puts @tree
    end

    # Return the tree
    @tree
  end

  # Creates a single node
  def produce(type)
    new_node = type.new(@node)
    new_node.value = @tokens[@next].value
    new_node.raw = @tokens[@next].raw
    new_node
  end

  # Returns true if the next token is equal to *type*
  # and optionally to *value*
  # Doesn't increment the @next pointer
  def peek_token(type, value = false)

    # Check if there are any tokens left
    if @next >= @tokens.size
      return false
    end

    # Mark the token as touched
    @tokens[@next].touched = true

    # Check for a match
    if value
      @tokens[@next].type == type && @tokens[@next].value == value
    else
      @tokens[@next].type == type
    end
  end

  def token(type, value = false)
    add_token(type, value, true)
  end

  # Returns true if the next token is equal to *type*
  # and optionally to *value*
  # Increments the @next pointer if the token was found
  def add_token(type, value = false, add_to_tree = true)
    match = peek_token(type, value)

    if match && add_to_tree
      case type
      when TokenType::Null
        @node << produce NullLiteral
      when TokenType::Numeric
        @node << produce NumericLiteral
      when TokenType::Identifier
        @node << produce IdentifierLiteral
      when TokenType::LeftParen
        @node << produce LeftParenLiteral
      when TokenType::RightParen
        @node << produce RightParenLiteral
      when TokenType::LeftCurly
        @node << produce LeftCurlyLiteral
      when TokenType::RightCurly
        @node << produce RightCurlyLiteral
      when TokenType::LeftBracket
        @node << produce LeftBracketLiteral
      when TokenType::RightBracket
        @node << produce RightBracketLiteral
      when TokenType::Point
        @node << produce PointLiteral
      when TokenType::Plus
        @node << produce PlusOperator
      when TokenType::Minus
        @node << produce MinusOperator
      when TokenType::Mult
        @node << produce MultOperator
      when TokenType::Divd
        @node << produce DivdOperator
      when TokenType::Mod
        @node << produce ModOperator
      when TokenType::Pow
        @node << produce PowOperator
      when TokenType::Semicolon
        @node << produce SemicolonLiteral
      when TokenType::Keyword
        @node << produce KeywordLiteral
      when TokenType::Assignment
        @node << produce AssignmentOperator
      when TokenType::Comma
        @node << produce CommaLiteral
      when TokenType::String
        @node << produce StringLiteral
      when TokenType::Boolean
        @node << produce BooleanLiteral
      when TokenType::Greater
        @node << produce GreaterOperator
      when TokenType::Less
        @node << produce LessOperator
      when TokenType::GreaterEqual
        @node << produce GreaterEqualOperator
      when TokenType::LessEqual
        @node << produce LessEqualOperator
      when TokenType::Equal
        @node << produce EqualOperator
      when TokenType::Not
        @node << produce NotOperator
      else
        puts "Unknown token found (#{type})"
      end
    end

    if match
      @next += 1
    end

    match
  end

  # Returns true if the next token is equal to *type*
  # and optionally to *value*
  # Increments the @next pointer if the token was found
  #
  # If the token was not found, the next pointer is not incremented
  # but the method still returns true
  def optional_token(type, value = false)
    add_token(type, value, true)
    true
  end

  # Behaves the same as token(type, value)
  # except that a matched node is not added to the tree
  def skip_token(type, value = false)
    add_token(type, value, false)
  end

  # Behaves the same as token(type, value)
  # except that a matched node is not added to the tree
  # and that it always returns true
  def skip_optional_token(type, value = false)
    add_token(type, value, false)
    true
  end

  # Runs each proc in *productions*
  # If a proc returns true
  # The result of the temporary production will be placed into the
  # current @tree
  def check_each(productions : Array(Production), type : ASTNode.class = Temporary)

    # Keep pointers to the real nodes
    next_save = @next
    node_save = @node

    # Try each production
    match = false
    productions.each do |production|

      # Skip if a production has already passed
      next if match

      # If production is a boolean, use it
      if production.is_a? Bool
        match = production
      end

      # If func was *true*, don't try the production
      if !match && production.is_a?(Prod)

        # Reset
        @next = next_save
        @node = node_save

        # Create temporary nodes
        temp = type.new @node
        @node = temp

        # Try the production
        match = production.call

        # Flush the temporary children to the real node
        # if the production passed
        if match
          @node = node_save
          temp.children.each do |child|
            @node << child
          end
        end
      end
    end

    match
  end

  # Tries to produce *type* with the given *productions*
  def node_production(type : ASTNode.class, *productions : Production)

    # Backup and temporary node creation
    node_save = @node
    @node = type.new @node

    # Try all productions
    match = check_each(productions.to_a, type)

    # Append the node to the tree if it passed
    if match
      node_save << @node
    end

    # Restore the original node and return
    @node = node_save
    match
  end

  def block
    skip_token(TokenType::LeftCurly) &&
    block_body &&
    skip_token(TokenType::RightCurly)
  end

  def block_body
    node_production(Block, ->{
      found_at_least_one = false
      while !peek_token(TokenType::RightCurly) && statement
        found_at_least_one = true unless found_at_least_one
      end
      found_at_least_one
    }, true)
  end

  def statement
    node_production(Statement, ->{
      match = false
      if token(TokenType::Keyword, "let") && token(TokenType::Identifier)
        match = check_each([->{
          token(TokenType::Assignment) && expression && skip_optional_token(TokenType::Semicolon)
        }, ->{
          skip_optional_token(TokenType::Semicolon)
        }])
      end
      match
    }, ->{
      token(TokenType::Keyword, "const") &&
      token(TokenType::Identifier) &&
      token(TokenType::Assignment) &&
      expression &&
      skip_optional_token(TokenType::Semicolon)
    }, ->{
      expression && skip_optional_token(TokenType::Semicolon)
    }, ->{
      if_statement && skip_optional_token(TokenType::Semicolon)
    }, ->{
      token(TokenType::Keyword, "while") &&
      skip_token(TokenType::LeftParen) &&
      expression &&
      skip_token(TokenType::RightParen) &&
      block &&
      skip_optional_token(TokenType::Semicolon)
    })
  end

  def if_statement
    node_production(IfStatement, ->{
      match = false
      if token(TokenType::Keyword, "if") &&
          skip_token(TokenType::LeftParen) &&
          expression &&
          skip_token(TokenType::RightParen) &&
          block

        # Parse the else or else if clause
        match = check_each([->{
          match = false
          if token(TokenType::Keyword, "else")
            match = check_each([->{
              block
            }, ->{
              if_statement
            }, true])
          end
          match
        }, true])
      end
      match
    })
  end

  def expression_list
    node_production(ExpressionList, ->{
      match = false
      if expression
        match = check_each([->{
          found_at_least_one = false

          # We are peeking before because we are expanding two different nodes
          while peek_token(TokenType::Comma) && skip_token(TokenType::Comma) && expression
            found_at_least_one = true unless found_at_least_one
          end
          found_at_least_one
        }, true])
      end
      match
    }, true)
  end

  def identifier_list
    node_production(IdentifierList, ->{
      match = false
      if token(TokenType::Identifier)
        match = check_each([->{
          found_at_least_one = false

          # We are peeking before because we are expanding two different nodes
          while peek_token(TokenType::Comma) && skip_token(TokenType::Comma) && token(TokenType::Identifier)
            found_at_least_one = true unless found_at_least_one
          end
          found_at_least_one
        }, true])
      end
      match
    }, true)
  end

  def expression
    node_production(Expression, ->{
      if unary_expression
        check_each([->{
          token(TokenType::Mult) && expression
        }, ->{
          token(TokenType::Divd) && expression
        }, ->{
          token(TokenType::Plus) && expression
        }, ->{
          token(TokenType::Minus) && expression
        }, ->{
          token(TokenType::Mod) && expression
        }, ->{
          token(TokenType::Pow) && expression
        }, ->{
          token(TokenType::Greater) && expression
        }, ->{
          token(TokenType::Less) && expression
        }, ->{
          token(TokenType::LessEqual) && expression
        }, ->{
          token(TokenType::GreaterEqual) && expression
        }, ->{
          token(TokenType::Equal) && expression
        }, ->{
          token(TokenType::Not) && expression
        }, ->{
          token(TokenType::Assignment) && expression
        }])
        return true
      end
      return false
    })
  end

  def unary_expression
    node_production(UnaryExpression, ->{
      check_each([->{
        token(TokenType::Minus) && term
      }, ->{
        token(TokenType::Not) && unary_expression
      }, ->{
        term
      }])
    })
  end

  def term
    node_production(Expression, ->{
      token(TokenType::Numeric) && consume_postfix
    }, ->{
      token(TokenType::String) && consume_postfix
    }, ->{
      token(TokenType::Boolean) && consume_postfix
    }, ->{
      token(TokenType::Null) && consume_postfix
    }, ->{
      token(TokenType::Identifier) && consume_postfix
    }, ->{
      skip_token(TokenType::LeftParen) &&
      expression &&
      skip_token(TokenType::RightParen) && consume_postfix
    }, ->{
      array_literal && consume_postfix
    }, ->{
      function_literal && consume_postfix
    }, ->{
      class_literal && consume_postfix
    }, ->{
      container_literal && consume_postfix
    })
  end

  def function_literal
    node_production(FunctionLiteral, ->{
      token(TokenType::Keyword, "func") &&
      optional_token(TokenType::Identifier) &&
      skip_token(TokenType::LeftParen) &&
      identifier_list &&
      skip_token(TokenType::RightParen) &&
      block
    })
  end

  def array_literal
    node_production(ArrayLiteral, ->{
      skip_token(TokenType::LeftBracket) &&
      expression_list &&
      skip_token(TokenType::RightBracket)
    })
  end

  def class_literal
    node_production(ClassLiteral, ->{
      token(TokenType::Keyword, "class") &&
      optional_token(TokenType::Identifier) &&
      block
    })
  end

  def container_literal
    node_production(ContainerLiteral, ->{
      block
    })
  end

  # Alias for consume_call_expression && consume_member_expression
  def consume_postfix
    consume_call_expression && consume_member_expression && consume_index_expression
  end

  def consume_call_expression
    if peek_token(TokenType::LeftParen)
      node_save = @node
      children_save = @node.children.dup
      @node.children.clear
      @node = @node.parent

      match = node_production(CallExpression, ->{
        left_side = node_save.class.new(node_save.parent)
        left_side.children = children_save
        @node << left_side

        skip_token(TokenType::LeftParen) &&
        expression_list &&
        skip_token(TokenType::RightParen) &&
        consume_postfix
      })
      @node = node_save
      return match
    end
    true
  end

  def consume_member_expression
    if peek_token(TokenType::Point)
      node_save = @node
      children_save = @node.children.dup
      @node.children.clear
      @node = @node.parent

      match = node_production(MemberExpression, ->{
        left_side = node_save.class.new(node_save.parent)
        left_side.children = children_save
        @node << left_side

        skip_token(TokenType::Point) &&
        token(TokenType::Identifier) &&
        consume_postfix
      })
      @node = node_save
      return match
    end
    true
  end

  def consume_index_expression
    if peek_token(TokenType::LeftBracket)
      node_save = @node
      children_save = @node.children.dup
      @node.children.clear
      @node = @node.parent

      match = node_production(IndexExpression, ->{
        left_side = node_save.class.new(node_save.parent)
        left_side.children = children_save
        @node << left_side

        skip_token(TokenType::LeftBracket) &&
        expression_list &&
        skip_token(TokenType::RightBracket) &&
        consume_postfix
      })
      @node = node_save
      return match
    end
    true
  end
end
