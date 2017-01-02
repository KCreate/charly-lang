require "./TreeVisitor.cr"

module Charly::AST

  # Dump a human-readable version of the AST
  class DumpVisitor < TreeVisitor

    # Catch all rule
    visit ASTNode do
      io.puts name node
      rest children
    end

    visit StringLiteral do
      io << name node
      io << " | "
      io.puts "\"#{node.value}\""
    end

    visit PrecalculatedValue, NumericLiteral, BooleanLiteral do
      io << name node
      io << " | "
      io.puts node.value
    end

    visit IdentifierLiteral, FunctionLiteral, ClassLiteral, PrimitiveClassLiteral do
      io << name node
      io << " | "
      io.puts "\"#{node.name}\""
      rest children
    end

    visit UnaryExpression, BinaryExpression, ComparisonExpression do
      io << name node
      io << " | "
      io.puts node.operator
      rest children
    end

    macro rest(children)
      {{children}}.each_with_index do |child, index|

        unless child.is_a? ASTNode
          next
        end

        str = String.build do |str|
          child.accept self, str
        end

        str.lines.each_with_index do |line, line_index|

          if line_index == 0
            if {{children}}.size > 1 && index < {{children}}.size - 1
              io << "├─"
            else
              io << "└─"
            end
          else
            if {{children}}.size > 1 && index < {{children}}.size - 1
              io << "│ "
            else
              io << "  "
            end
          end

          io << " "
          io << line

          io << "\n"
        end
      end
    end

  end

end
