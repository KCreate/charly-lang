require "../ast/ast.cr"

# Change the structure of the program
# e.g: Expressions that are nested twice should be resolved
# etc.
class Structure
  property program : ASTNode
  property finished : Bool

  def initialize(program)
    @program = program
    @finished = false
  end

  def start

    # Check if a program was put into the structurizer
    unless @program.is_a? Program
      raise "Not a program"
    end

    # Run the restructure step until finished is set to true
    while !@finished
      @finished = true
      structure @program
    end
  end

  # Restructure a node and all children
  def structure(node)

    i = 0
    while i < node.children.size
      node.children[i].parent = node
      node.children[i] = structure node.children[i]
      node.children[i].parent = node
      i += 1
    end

    # Nodes that tend to only contain a single node
    if node.is_a?(Expression) ||
        node.is_a?(UnaryExpression) ||
        node.is_a?(MemberExpression) ||
        node.is_a?(IndexExpression) ||
        node.is_a?(CallExpression) ||
        node.is_a?(Statement)

      # Check the size of the children
      if node.children.size == 1
        @finished = false
        return node.children[0]
      end
    end

    # Binary Expressions
    if node.is_a?(Expression) && node.children.size == 3

      # Check for the arithmetic operator
      if node.children[1].is_a? OperatorLiteral
        @finished = false
        new_node = BinaryExpression.new(node)
        new_node << node.children[0]
        new_node << node.children[1]
        new_node << node.children[2]
        return new_node
      end
    end

    # Comparison Expressions
    if node.is_a?(Expression) && node.children.size == 3

      # Check for the comparison operator
      if node.children[1].is_a? ComparisonOperatorLiteral
        @finished = false
        new_node = ComparisonExpression.new(node)
        new_node << node.children[0]
        new_node << node.children[1]
        new_node << node.children[2]
        return new_node
      end
    end

    # Variable Declarations
    if node.is_a?(Statement) && node.children.size == 2

      # Check for the let keyword
      if node.children[0].is_a? KeywordLiteral && node.children[0].value == "let"
        @finished = false
        new_node = VariableDeclaration.new(node)
        new_node << node.children[1]
        return new_node
      end
    end

    # Variable Initialisations
    if node.is_a?(Statement) && node.children.size == 4

      # Check for the let keyword and the assignment operator
      if node.children[0].is_a? KeywordLiteral && node.children[0].value == "let"
        if node.children[2].is_a? AssignmentOperator
          @finished = false
          new_node = VariableInitialisation.new(node)
          new_node << node.children[1]
          new_node << node.children[3]
          return new_node
        end
      end

      # Check for the const keyword and the assignment operator
      if node.children[0].is_a? KeywordLiteral && node.children[0].value == "const"
        if node.children[2].is_a? AssignmentOperator
          @finished = false
          new_node = ConstantInitialisation.new(node)
          new_node << node.children[1]
          new_node << node.children[3]
          return new_node
        end
      end
    end

    # Assignments
    if node.is_a?(Expression) && node.children.size == 3

      # Check for the assignment operator
      if node.children[1].is_a? AssignmentOperator
        @finished = false
        new_node = VariableAssignment.new(node)
        new_node << node.children[0]
        new_node << node.children[2]
        return new_node
      end
    end

    # While statements
    if node.is_a?(Statement) && node.children.size == 3

      # Check for the while keyword
      if node.children[0].is_a? KeywordLiteral && node.children[0].value == "while"
        @finished = false
        new_node = WhileStatement.new(node)
        new_node << node.children[1]
        new_node << node.children[2]
        return new_node
      end
    end

    # Strip the func keyword from the FunctionLiterals
    if node.is_a?(FunctionLiteral) && (node.children.size == 4 || node.children.size == 3)

      # Check for the func keyword
      if node.children[0].is_a?(KeywordLiteral) && node.children[0].value == "func"
        @finished = false
        node.anonymous = node.children.size == 3
        node.children.shift # Remove the func keyword
        return node
      end
    end

    # A function literal inside a block is a variable initialisation
    if node.is_a?(FunctionLiteral) && node.children.size == 3 && node.parent.is_a?(Block)
      @finished = false
      new_node = VariableInitialisation.new(node.parent)
      new_node << node.children.shift
      new_node << node
      return new_node
    end

    # A class literal inside a block is a variable initialisation
    if node.is_a?(ClassLiteral) && node.parent.is_a?(Block)
      @finished = false
      new_node = VariableInitialisation.new(node.parent)
      new_node << node.children[0]
      new_node << node
      node.children.shift
      return new_node
    end

    # A class literal as an expression shouldn't have a name
    if node.is_a?(ClassLiteral) && node.children.size == 2
      @finished = false
      node.children.shift
      return node
    end

    # If statements
    if node.is_a?(IfStatement)

      # Ifs without a else block
      if node.children.size == 3 &&
          node.children[0].is_a?(KeywordLiteral) &&
          node.children[0].value == "if"
        @finished = false
        node.children.shift
      end

      # Ifs with a else block
      if node.children.size == 5 &&
          (node.children[4].is_a?(Block) || node.children[4].is_a?(IfStatement))
        node.children.delete_at(3)
        node.children.delete_at(0)
        @finished = false
      end
    end

    # Class Literals
    if node.is_a?(ClassLiteral) && node.children.size == 3

      # Remove the class keyword
      node.children.shift
    end

    # Remove the expressionlist from arrayliterals
    if node.is_a?(ArrayLiteral) && (node.children.size > 0) && node.children[0].is_a?(ExpressionList)
      node.children[0].children.each do |child|
        node << child
        child.parent = node
      end
      node.children.shift
      @finished = false
    end

    node
  end
end
