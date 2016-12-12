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
          left = TNumeric.new left.value
          right = TNumeric.new right.value

          value = Calculator.visit(operator, left, right)

          case value
          when TNumeric
            return NumericLiteral.new(value.value).at(node.location_start, node.location_end)
          when TString
            return StringLiteral.new(value.value).at(node.location_start, node.location_end)
          else
            raise Exception.new("Constant Folder Transformation produced faulty result: #{value} for #{node}")
          end
        end
      end

      node
    end
  end
end
