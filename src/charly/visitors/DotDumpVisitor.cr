require "./TreeVisitor.cr"

module Charly::AST

  # Dumps "dot-language" of a given ASTNode
  class DotDumpVisitor < TreeVisitor
    property next_id = 0

    HEADER = <<-HEADER
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

    # Render the dot-language for a given ASTNode
    def render(node : ASTNode, io : IO)
      io.puts "digraph astgraph {"
      io.puts HEADER.indent(2, " ")
      content = IO::Memory.new
      node.accept self, content
      io.puts content.to_s.indent(2, " ")
      io.puts "}"
    end

    visit ASTNode do
      id = @next_id
      @next_id += 1
      io.puts "node#{id} [label=\"#{name node}\"];"
      rest node.children, id
    end

    visit StringLiteral do
      id = @next_id
      @next_id += 1
      io.puts "node#{id} [label=\"#{quote node.value}\"];"
      rest node.children, id
    end

    visit NumericLiteral, BooleanLiteral do
      id = @next_id
      @next_id += 1
      io.puts "node#{id} [label=\"#{node.value}\"];"
      rest node.children, id
    end

    visit UnaryExpression, BinaryExpression, ComparisonExpression do
      id = @next_id
      @next_id += 1
      io.puts "node#{id} [label=\"#{name node} - #{node.operator}\"];"
      rest node.children, id
    end

    visit IdentifierLiteral do
      id = @next_id
      @next_id += 1

      io.puts "node#{id} [label=\"IdentifierLiteral\"];"
      string node.name, id, io

      rest node.children, id
    end

    visit FunctionLiteral do
      id = @next_id
      @next_id += 1

      io.puts "node#{id} [label=\"FunctionLiteral\"];"
      string node.name, id, io

      rest node.children, id
    end

    visit ClassLiteral do
      id = @next_id
      @next_id += 1

      io.puts "node#{id} [label=\"ClassLiteral\"];"
      string node.name, id, io

      rest node.children, id
    end

    visit PrimitiveClassLiteral do
      id = @next_id
      @next_id += 1

      io.puts "node#{id} [label=\"PrimitiveClassLiteral\"];"
      string node.name, id, io

      rest node.children, id
    end

    macro rest(children, parent)
      {{children}}.each do |child|
        child_id = @next_id
        child.accept self, io
        io.puts "node#{{{parent}}} -> node#{child_id};"
      end
    end

    private def quote(string)
      "\\\"#{string}\\\""
    end

    private def string(string, parent, io)
      io.puts "node#{@next_id} [label=\"#{quote string}\"];"
      io.puts "node#{parent} -> node#{@next_id};"

      @next_id += 1
    end
  end

end
