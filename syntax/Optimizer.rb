require_relative "../misc/Helper.rb"
require_relative "Parser.rb"
require_relative "AST.rb"

# Optimizes a program to be more efficient
# Doesn't always produce the "perfect" program
class Optimizer

  def initialize
    @finished = false
  end

  # Optimize a program
  def optimize_program(program)
    if !program.is Program
      raise "Not a Program instance"
    end

    dlog "Optimizing program structure"
    while !@finished
      @finished = true
      optimize :structure, program
    end

    # Reset @finished
    @finished = false

    dlog "Generating abstract syntax tree groupings"
    while !@finished
      @finished = true
      optimize :group, program, true
    end

    program
  end

  # Optimize a node with a given flow
  # options are:
  # - structure
  # - group
  def optimize(flow, node, after = false)

    # Backup the parent
    parent_save = node.parent

    # Call the entry handler
    unless after
      case flow
      when :structure
        node = flow_structure node
      when :group
        node = flow_group node
      end

      # Return if the node returned NIL
      if node == NIL
        return NIL
      end

      # Correct the parent pointer
      node.parent = parent_save
    end


    # Optimize all children and remove nil values afterwards
    node.children.collect! do |child|

      if child == NIL
        next
      end

      case flow
      when :structure
        optimize :structure, child, after
      when :group
        optimize :group, child, after
      end
    end
    node.children = node.children.compact

    # Call the leave handler
    if after
      case flow
      when :structure
        node = flow_structure node
      when :group
        node = flow_group node
      end

      # Return if the node returned NIL
      if node == NIL
        return NIL
      end

      # Correct the parent pointer
      node.parent = parent_save
    end

    node
  end

  # Optimize the structure of a node
  def flow_structure(node)

    # Correct the parent pointer of all children
    node.children.each do |child|
        child.parent = node
    end

    # NumericLiterals value property should be an actual float value
    if node.is(NumericLiteral) && node.value.is_a?(String)
      node.value = node.value.to_f
      @finished = false
      return node
    end

    # BooleanLiterals value property should be an actual boolean
    if node.is(BooleanLiteral) && node.value.is_a?(String)
      node.value = node.value == "true"
      @finished = false
      return node
    end

    # Expressions that only contain 1 other expression
    # should be replaced by that expression
    if node.is(Expression) && node.children.length == 1
      if node.children[0].is(Expression)
        @finished = false
        return node.children[0]
      end
    end

    # Expressions containing 3 children and last and first ones are parens
    if node.is(Expression) && node.children.length == 3
      if node.children[0].is(LeftParenLiteral) && node.children[2].is(RightParenLiteral)
        if node.children[1].is(Expression)
          @finished = false
          return node.children[1]
        end
      end
    end

    # Expression that only contain terminal nodes
    # that can be treated as expressions
    # should be replaced by that nodes
    if node.is(Expression) && node.children.length == 1
      if node.children[0].is LiteralValue
        @finished = false
        return node.children[0]
      end
    end

    # Strip semicolons, commas
    if node.is(CommaLiteral, SemicolonLiteral, LeftBracketLiteral, RightBracketLiteral)
      @finished = false
      return NIL
    end

    node
  end

  # Optimize the groupings of the node
  def flow_group(node)

    # Unary Expressions
    if node.is(Expression) && node.children.length == 2 && !node.is(UnaryExpression)

      # Check for the operator
      if node.children[0].is(OperatorLiteral)
        operator = node.children[0]
        right = node.children[1]

        # Typecheck right side
        if right.is Expression, LiteralValue
          @finished = false
          return UnaryExpression.new(operator, right, node.parent)
        end
      end
    end

    # Arithmetic expressions involving an operator
    if node.is(Expression) && node.children.length == 3 && !node.is(BinaryExpression)

      # Check for the operator
      if node.children[1].is(OperatorLiteral)

        # Typecheck left and right argument
        left = node.children[0]
        right = node.children[2]
        operator = node.children[1]

        if left.is Expression, LiteralValue
          if right.is Expression, LiteralValue

            @finished = false
            return BinaryExpression.new(operator, left, right, node.parent)
          end
        end
      end
    end

    # Comparison expressions involving an operator
    if node.is(Expression) && node.children.length == 3 && !node.is(ComparisonExpression)

      # Check for the operator
      if node.children[1].is(ComparisonOperatorLiteral)

        # Typecheck left and right argument
        left = node.children[0]
        right = node.children[2]
        operator = node.children[1]

        if left.is Expression, LiteralValue
          if right.is Expression, LiteralValue,

            @finished = false
            return ComparisonExpression.new(operator, left, right, node.parent)
          end
        end
      end
    end

    # Assignment operator
    if node.is(Expression) && node.children.length == 3

      # Check for the operator
      if node.children[1].is(AssignmentOperator)

        # Typecheck left and right argument
        identifier = node.children[0]
        expression = node.children[2]
        operator = node.children[1]

        if expression.is Expression, LiteralValue, MemberExpression
          if identifier.is IdentifierLiteral, MemberExpression
            @finished = false
            return VariableAssignment.new(identifier, expression, node.parent)
          elsif identifier.is CallExpression
            @finished = false

            # Get the needed information to get to the array
            array_identifier = identifier.identifier
            array_location = identifier.argumentlist
            return ArrayIndexWrite.new(array_identifier, array_location, expression, node.parent)
          end
        end
      end
    end

    # Declarations
    if node.is_exact(Statement) && node.children.length == 2

      # Check for the let keyword
      if node.children[0].value == "let"
        if node.children[1].is(IdentifierLiteral)

          @finished = false
          return VariableDeclaration.new(node.children[1], node.parent)
        end
      end
    end

    # Variable initialisations
    if node.is(Statement) && node.children.length == 4
      child1 = node.children[0]
      child2 = node.children[1]
      child3 = node.children[2]
      child4 = node.children[3]

      if child1.is(KeywordLiteral) && child1.value == "let"
        if child2.is(IdentifierLiteral) && child3.is(AssignmentOperator)
          if child4.is(Expression, LiteralValue)

            @finished = false
            return VariableInitialisation.new(child2, child4, node.parent)
          end
        end
      end
    end

    # Call Expressions
    if node.is(Expression) && node.children.length == 4
      child1 = node.children[0]
      child2 = node.children[1]
      child3 = node.children[2]
      child4 = node.children[3]

      if child3.is(ExpressionList)
        if child2.is(LeftParenLiteral) && child4.is(RightParenLiteral)

          @finished = false
          return CallExpression.new(child1, child3, node.parent)
        end
      end
    end

    # Member Expressions
    if node.is(MemberExpressionNode)

      # Check for the point
      if node.children[1].is(PointLiteral)

        @finished = false
        return MemberExpression.new(node.children[0], node.children[2], node.parent)
      end
    end

    # Class Literals
    if node.is(ClassLiteralNode) && node.children.length == 5

      # Get the identifier and the block
      identifier = node.children[1]
      block = node.children[3]

      # Search for a FunctionDefinition with the identifier *new* inside the block
      constructor = nil
      block.children.each do |child|
        if child.is(FunctionDefinitionExpression) && child.function.identifier.value == "constructor"
          constructor = child.function
        end
      end

      # Create the new ClassLiteral
      @finished = false
      return ClassLiteral.new(identifier, constructor, block, node.parent)
    end

    # Function literals
    if node.is(Expression) && (node.children.length == 8 || node.children.length == 7)
      child1 = node.children[0]
      child2 = node.children[1]
      child3 = node.children[2]
      child4 = node.children[3]
      child5 = node.children[4]
      child6 = node.children[5]
      child7 = node.children[6]
      child8 = node.children[7]

      # Check for the func keyword
      if child1.value == "func"

        # Check if an identifier was passed
        if node.children.length == 8

          # Check for braces and parens
          if child3.is(LeftParenLiteral) && child5.is(RightParenLiteral) &&
            child6.is(LeftCurlyLiteral) && child8.is(RightCurlyLiteral)

            # Check for the block and the argumentlist
            if child4.is(ArgumentList) && child7.is(Block)

              @finished = false
              return FunctionLiteral.new(child2, child4, child7, node.parent)
            end
          end
        else

          # Check for braces and parens
          if child2.is(LeftParenLiteral) && child4.is(RightParenLiteral) &&
            child5.is(LeftCurlyLiteral) && child7.is(RightCurlyLiteral)

            # Check for the block and the argumentlist
            if child3.is(ArgumentList) && child6.is(Block)

              @finished = false
              return FunctionLiteral.new(nil, child3, child6, node.parent)
            end
          end
        end
      end
    end

    # Statements only containing IfStatementPrimitives or IfStatement, should be replaced by that child
    if node.is(Statement) && node.children.length == 1
      if node.children[0].is(IfStatementPrimitive, IfStatement)
        @finished = false
        return node.children[0]
      end
    end

    # Group IfStatementPrimitives with the signature (if)
    if node.is(IfStatementPrimitive) && node.children.length == 7
      if node.children[2].is(Expression, LiteralValue) && node.children[5].is(Block)
        @finished = false
        return IfStatement.new(node.children[2], node.children[5], NIL, node.parent)
      end
    end

    # Group IfStatementPrimitives with the signature (if else)
    if node.is(IfStatementPrimitive) && node.children.length == 11
      if node.children[2].is(Expression, LiteralValue) && node.children[5].is(Block) && node.children[9].is(Block)
        @finished = false
        return IfStatement.new(node.children[2], node.children[5], node.children[9], node.parent)
      end
    end

    # Group IfStatementPrimitives with the signature (if else)
    if node.is(IfStatementPrimitive) && node.children.length == 9
      if node.children[2].is(Expression, LiteralValue) && node.children[5].is(Block) &&
          node.children[8].is(IfStatement)
        @finished = false
        return IfStatement.new(node.children[2], node.children[5], node.children[8], node.parent)
      end
    end

    # While statements
    if node.is(Statement) && node.children.length == 7
      if node.children[0].value == "while"
        @finished = false
        return WhileStatement.new(node.children[2], node.children[5], node.parent)
      end
    end

    # Function definitions
    if node.is(Statement) && node.children.length == 1
      if node.children[0].is(FunctionLiteral)

        @finished = false
        return FunctionDefinitionExpression.new(node.children[0], node.parent)
      end
    end

    # Class Definitions
    if node.is(Statement) && node.children.length == 1
      if node.children[0].is(ClassLiteral)
        @finished = false
        return ClassDefinition.new(node.children[0], node.parent)
      end
    end

    return node
  end
end
