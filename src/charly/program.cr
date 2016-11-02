require "./syntax/token.cr"
require "./syntax/ast.cr"

module Charly
  class Program
    property path : String
    property source : String
    property tree : AST::Block

    def initialize(@path, @tree, @source)
    end
  end
end
