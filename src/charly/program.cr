require "./syntax/ast.cr"

module Charly
  class Program
    property path : String
    property tree : AST::Block

    def initialize(@path, @tree)
    end
  end
end
