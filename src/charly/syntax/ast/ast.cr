require "../../helper.cr"
require "../../interpreter/stack/stack.cr"
require "../../file.cr"

abstract class ASTNode
  property children : Array(ASTNode)
  property! parent : ASTNode
  property! value : Bool | Float64 | String
  property linked : Bool

  def initialize(parent)
    @parent = parent
    @children = [] of ASTNode
    @linked = false
  end

  # Appends *node* to the children of this node
  def <<(node)
    @children << node
    node.parent = self
  end

  # Correct the parent pointers of all children
  def children=(new_children)
    new_children.each do |child|
      child.parent = self
    end
    @children = new_children
  end

  # Render the current node
  def to_s(io)
    io << "#: #{self.class.name}"

    if @value.is_a?(String | Float64 | Bool)
      io << " - #{@value}"
    end

    if @children.size > 0
      io << " - #{@children.size} children"
    end

    io << "\n"

    children.each do |child|
      lines = child.to_s.each_line.each
      lines.each do |line|
        if line[0] == '#'
          io << line.indent(1, "├╴")
        elsif line.size > 0
          io << line.indent(1, "│ ")
        end
      end
    end
  end
end

# Temporary node used while parsing and constructing tree nodes
# Allows to quickly throw away failed productions
class Temporary < ASTNode
end

# A block containing statements
class Block < ASTNode
  property parent_stack : Stack?
end

# A single program with no parent nodes
class Program < ASTNode
  property file : VirtualFile?
  property should_execute = true
end

# A single statement in a block
class Statement < ASTNode
end

# An if statement
class IfStatement < ASTNode
  property test : ASTNode?
  property consequent : ASTNode?
  property alternate : ASTNode?
end

# While loops
class WhileStatement < ASTNode
  property test : ASTNode?
  property consequent : ASTNode?
end

# A single expression
class Expression < ASTNode
end

# A single unary expression
class UnaryExpression < ASTNode
  property operator : ASTNode?
  property right : ASTNode?
end

# A single binary expression
class BinaryExpression < ASTNode
  property operator : ASTNode?
  property left : ASTNode?
  property right : ASTNode?
end

# A single comparison expression
class ComparisonExpression < ASTNode
  property operator : ASTNode?
  property left : ASTNode?
  property right : ASTNode?
end

# A variable declaration
class VariableDeclaration < ASTNode
  property identifier : ASTNode?
end

# A variable initialisation
class VariableInitialisation < ASTNode
  property identifier : ASTNode?
  property expression : ASTNode?
end

# A variable assignment
class VariableAssignment < ASTNode
  property identifier : ASTNode?
  property expression : ASTNode?
end

# A class literal
class ClassLiteral < ASTNode
  property block : ASTNode?
end

# A single call expression
class CallExpression < ASTNode
  property identifier : ASTNode?
  property argumentlist : ASTNode?
end

# A single member expression
class MemberExpression < ASTNode
  property identifier : ASTNode?
  property member : ASTNode?
end

# A single index expression
class IndexExpression < ASTNode
  property identifier : ASTNode?
  property member : ASTNode?
end

# A list of expressions seperated by commas
class ExpressionList < ASTNode
  def each
    @children.each do |child|
      yield child
    end
  end
end

# A list of identifier seperated by commas
class IdentifierList < ASTNode
end

# A terminal node
class Terminal < ASTNode
  property raw : String?
end

# Literals
class LiteralValue < Terminal; end
class NullLiteral < LiteralValue; end
class IdentifierLiteral < LiteralValue; end
class StringLiteral < LiteralValue; end
class NumericLiteral < LiteralValue; end
class KeywordLiteral < LiteralValue; end
class BooleanLiteral < LiteralValue; end
class ArrayLiteral < ASTNode; end
class FunctionLiteral < ASTNode
  property argumentlist : ASTNode?
  property block : ASTNode?
  property anonymous : Bool?
end
class ContainerLiteral < ASTNode
  property block : ASTNode?
end

# Structure
class LeftParenLiteral < Terminal; end
class RightParenLiteral < Terminal; end
class LeftCurlyLiteral < Terminal; end
class RightCurlyLiteral < Terminal; end
class LeftBracketLiteral < Terminal; end
class RightBracketLiteral < Terminal; end

# Punctuators
class SemicolonLiteral < Terminal; end
class CommaLiteral < Terminal; end
class PointLiteral < Terminal; end

# Misc. Operators
class AssignmentOperator < Terminal; end

# Arithmetic operators
class OperatorLiteral < Terminal; end
  class PlusOperator < OperatorLiteral; end
  class MinusOperator < OperatorLiteral; end
  class MultOperator < OperatorLiteral; end
  class DivdOperator < OperatorLiteral; end
  class ModOperator < OperatorLiteral; end
  class PowOperator < OperatorLiteral; end

# Comparisons
class ComparisonOperatorLiteral < Terminal; end
  class LessOperator < ComparisonOperatorLiteral; end
  class GreaterOperator < ComparisonOperatorLiteral; end
  class LessEqualOperator < ComparisonOperatorLiteral; end
  class GreaterEqualOperator < ComparisonOperatorLiteral; end
  class EqualOperator < ComparisonOperatorLiteral; end
  class NotOperator < ComparisonOperatorLiteral; end
