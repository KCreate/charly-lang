require "../syntax/ast.cr"

# Simple interface to transform arbitrary AST Nodes
module Charly
  abstract class Transformation
    property tree : ASTNode

    def initialize(@tree)
    end

    def self.transform(tree : ASTNode)
      self.new(tree).transform
    end

    def transform
      transform @tree
    end

    def transform(node : ASTNode)
      node = visit_pre_order node

      i = 0
      while i < node.children.size
        child = node.children[i]
        transformed = transform child

        if transformed
          node.children[i] = transformed
        else
          node.children.delete_at i
        end

        i += 1
      end

      return visit_post_order node
    end

    def visit_pre_order(node : ASTNode)
      node
    end

    def visit_post_order(node : ASTNode)
      node
    end
  end
end

