require "../syntax/ast.cr"

module Charly::AST

  # Visits a given node and it's children
  abstract class TreeVisitor
    abstract def visit(node : ASTNode, io : IO)
  end

end
