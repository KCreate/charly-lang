require "../ast/ast.cr"

# Link the nodes instance variables to their children
# This is just for pure convenience when writing the interpreter
class Linker
  property program : ASTNode
  property finished : Bool

  def initialize(program)
    @program = program
    @finished = false
  end

  def start

    # Check if a program is given
    unless @program.is_a? Program
      raise "Not a program"
    end

    # This should only run once
    link @program
  end

  # Restructure a node and all children
  def link(node)

    # Iterate over all children first
    # This means we traverse the tree down-to-top
    i = 0
    while i < node.children.size
      link node.children[i]
      i += 1
    end

    # Don't link anything if the node is already linked
    if node.linked
      return
    end

    if node.is_a? BinaryExpression
      node.linked = true
      node.operator = node.children[1]
      node.left = node.children[0]
      node.right = node.children[2]
      return
    end

    if node.is_a? CallExpression
      node.linked = true
      node.identifier = node.children[0]
      node.argumentlist = node.children[1]
      return
    end

    if node.is_a? ContainerLiteral
      node.linked = true
      node.block = node.children[0]
      return
    end

    if node.is_a? ClassLiteral
      node.linked = true
      node.block = node.children[0]
      return
    end

    if node.is_a? ComparisonExpression
      node.linked = true
      node.operator = node.children[1]
      node.left = node.children[0]
      node.right = node.children[2]
      return
    end

    if node.is_a? FunctionLiteral
      node.linked = true

      # Check if this is an anonymous function
      if node.children.size == 3
        node.argumentlist = node.children[1]
        node.block = node.children[2]
      else
        node.argumentlist = node.children[0]
        node.block = node.children[1]
      end

      return
    end

    if node.is_a? IfStatement
      node.linked = true

      # Check if there is an else statement
      if node.children.size == 3
        node.test = node.children[0]
        node.consequent = node.children[1]
        node.alternate = node.children[2]
      else
        node.test = node.children[0]
        node.consequent = node.children[1]
      end

      return
    end

    if node.is_a? MemberExpression
      node.linked = true
      node.identifier = node.children[0]
      node.member = node.children[1]
      return
    end

    if node.is_a? IndexExpression
      node.linked = true
      node.identifier = node.children[0]
      node.member = node.children[1]
      return
    end

    if node.is_a? UnaryExpression
      node.linked = true
      node.operator = node.children[0]
      node.right = node.children[1]
      return
    end

    if node.is_a? VariableAssignment
      node.linked = true
      node.identifier = node.children[0]
      node.expression = node.children[1]
      return
    end

    if node.is_a? VariableDeclaration
      node.linked = true
      node.identifier = node.children[0]
      return
    end

    if node.is_a? VariableInitialisation
      node.linked = true
      node.identifier = node.children[0]
      node.expression = node.children[1]
      return
    end

    if node.is_a? ConstantInitialisation
      node.linked = true
      node.identifier = node.children[0]
      node.expression = node.children[1]
      return
    end

    if node.is_a? WhileStatement
      node.linked = true
      node.test = node.children[0]
      node.consequent = node.children[1]
      return
    end

    node
  end
end
