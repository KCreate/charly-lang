require "./TreeVisitor.cr"

module Charly::AST

  # Dumps "dot-language" of a given ASTNode
  class DotDumpVisitor < TreeVisitor
    property content
    @@next_id = 0

    HEADER = <<-HEADER
    digraph astgraph {
      node [
        shape=rectangle,
        fontsize=10,
        fontname="SF Mono",
        width=1.6,
        height=.1,
        margin=.05
      ];
      ranksep=.3;
      splines=ortho;
      edge [arrowsize=0]
    HEADER

    def initialize
      @content = IO::Memory.new 0
    end

    def render(io : IO)
      io.puts HEADER
      io.puts @content.to_s.indent(2, " ")
      io.puts "}"
    end

    macro visit(type, meta, properties)
      def visit(node : {{type}}, io : IO)
        id = @@next_id
        io.puts "node#{id} [label=\"#{node.class.name.split("::").last}\\n#{{{meta}}}\"];"
        @@next_id += 1
        io << render_node id, {{properties}}
        id
      end
    end

    macro visit(type, properties)
      def visit(node : {{type}}, io : IO)
        id = @@next_id
        io.puts "node#{id} [label=\"#{node.class.name.split("::").last}\"];"
        @@next_id += 1
        io << render_node id, {{properties}}
        id
      end
    end

    macro visit(type)
      def visit(node : {{type}}, io : IO)
        id = @@next_id
        io.puts "node#{id} [label=\"#{node.class.name.split("::").last}\"];"
        @@next_id += 1
        id
      end
    end

    visit ASTNode

    visit PrecalculatedValue, node.value, [] of ASTNode
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

    private def render_node(parent_id, children)
      String.build do |io|
        children.each_with_index do |node, index|

          unless node.is_a? ASTNode
            next
          end

          id = 0
          str = String.build do |str|
            id = node.accept self, str
          end

          str.lines.each do |line|
            io << line
            io << "\n"
          end

          io.puts "node#{parent_id} -> node#{id};"
        end
      end
    end
  end

end
