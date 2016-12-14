require "./transformation.cr"

# Fold constant expressions such as 1 + 2 into just 3
module Charly
  class ConstantFoldingTransformation < Transformation
    def visit_post_order(node : ASTNode)
      if node.is_a? BinaryExpression

        operator = node.operator
        left = node.children[0]
        right = node.children[1]

        if AST.is_primitive(left) && AST.is_primitive(right)
          left = BaseType.from left
          right = BaseType.from right

          value = Calculator.visit(operator, left, right)
          return AST::PrecalculatedValue.new(value).at(node)
        end
      end

      node
    end
  end
end
