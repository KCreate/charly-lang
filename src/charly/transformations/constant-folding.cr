require "./transformation.cr"

# Fold constant expressions such as 1 + 2 into just 3
module Charly
  class ConstantFoldingTransformation < Transformation
    def visit_post_order(node : ASTNode)
      if node.is_a? BinaryExpression

        operator = node.operator
        left = node.children[0]
        right = node.children[1]

        if left.is_a? NumericLiteral && right.is_a? NumericLiteral
          case operator
          when TokenType::Plus
            return NumericLiteral.new(left.value + right.value).at(left.location_start, right.location_end)
          end
        end
      end

      node
    end
  end
end
