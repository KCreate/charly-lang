require "./TreeVisitor.cr"

module Charly::AST

  # Used to dump a human-readable version of the AST
  class DumpVisitor < TreeVisitor
    def visit(node, io)
    end
  end

end
