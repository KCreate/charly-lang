require "./TreeVisitor.cr"

module Charly::AST

  # Used to dump a human-readable version of the AST
  class DumpVisitor < TreeVisitor
    macro visit(type, meta, properties)
      def visit(node : {{type}}, io : IO)
        io << node.class.name.split("::").last
        io << " | "
        io.puts {{meta}}

        io << render_node {{properties}}
      end
    end

    macro visit(type, properties)
      def visit(node : {{type}}, io : IO)
        io.puts node.class.name.split("::").last
        io << render_node {{properties}}
      end
    end

    macro visit(type)
      def visit(node : {{type}}, io : IO)
        io.puts node.class.name.split("::").last
      end
    end

    visit ASTNode

    visit PrecalculatedValue, [node.value]
    visit Block, node.children

    visit IfStatement, [node.test, node.consequent, node.alternate]
    visit GuardStatement, [node.test, node.alternate]
    visit UnlessStatement, [node.test, node.consequent, node.alternate]

    visit WhileStatement, [node.test, node.consequent]
    visit UntilStatement, [node.test, node.consequent]
    visit LoopStatement, [node.consequent]

    visit UnaryExpression, node.operator, [node.right]
    visit BinaryExpression, node.operator, [node.left, node.right]
    visit ComparisonExpression, node.operator, [node.left, node.right]

    visit And, [node.left, node.right]
    visit Or, [node.left, node.right]

    visit VariableInitialisation, [node.identifier, node.expression]
    visit VariableAssignment, [node.identifier, node.expression]
    visit ConstantInitialisation, [node.identifier, node.expression]

    visit CallExpression, [node.identifier, node.argumentlist]
    visit MemberExpression, [node.identifier, node.member]
    visit IndexExpression, [node.identifier, node.argument]

    visit ExpressionList, node.children
    visit IdentifierList, node.children

    visit ReturnStatement, [node.expression]
    visit ThrowStatement, [node.expression]

    visit TryCatchStatement, [node.try_block, node.exception_name, node.catch_block]

    visit IdentifierLiteral, node.name, [] of ASTNode
    visit ReferenceIdentifier, [node.identifier]
    visit StringLiteral, node.value, [] of ASTNode
    visit NumericLiteral, node.value, [] of ASTNode
    visit BooleanLiteral, node.value, [] of ASTNode
    visit ArrayLiteral, node.children
    visit FunctionLiteral, node.name, [node.argumentlist, node.block]
    visit ContainerLiteral, [node.block]
    visit ClassLiteral, node.name, [node.block, node.parents]
    visit PrimitiveClassLiteral, node.name, [node.block]
    visit PropertyDeclaration, [node.identifier]
    visit StaticDeclaration, [node.node]

    private def render_node(children)
      String.build do |io|
        children.each_with_index do |node, index|

          unless node.is_a? ASTNode
            next
          end

          str = String.build do |str|
            node.accept self, str
          end

          str.lines.each_with_index do |line, line_index|

            if line_index == 0
              if children.size > 1 && index < children.size - 1
                io << "├─"
              else
                io << "└─"
              end
            else
              if children.size > 1 && index < children.size - 1
                io << "│ "
              else
                io << " "
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

end
