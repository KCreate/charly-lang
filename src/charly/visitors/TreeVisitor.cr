require "../syntax/ast.cr"

module Charly::AST

  # Visits a given node and it's children
  abstract class TreeVisitor
    macro visit(type)
      def visit(node : {{type}}, io : IO)
        children = node.children
        {{yield}}
      end
    end

    macro visit(*types)
      {% for type in types %}
        visit {{type}} do
          {{yield}}
        end
      {% end %}
    end

    private def name(node)
      node.class.name.split("::").last
    end
  end

end
