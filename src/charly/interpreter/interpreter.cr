require "../program.cr"
require "../syntax/parser.cr"
require "./container.cr"
require "./types.cr"
require "./context.cr"

module Charly
  include AST

  alias Scope = Container(BaseType)

  # Single trace entry for callstacks
  private struct Trace
    property name : String
    property node : ASTNode
    property top : Scope

    def initialize(@name, @node, @top)
    end
  end

  # The interpreter takes a Program instance and executes the tree recursively.
  class Interpreter
    property top : Scope
    property trace : Array(Trace)

    # Creates a new Interpreter inside *top*
    # Setting *load_prelude* to false will prevent loading the prelude file
    def initialize(@top : Scope, load_prelude : Bool = true)
      @trace = [] of Trace

      # Load the prelude if *load_prelude* is set to true
      if load_prelude

        # Check if the prelude exists
        prelude_path = File.real_path(ENV["CHARLYDIR"] + "/src/std/prelude.charly")
        if File.readable?(prelude_path)
          program = Parser.create(File.open(prelude_path), prelude_path)
          exec_program(program, @top)
        else
          raise IOException.new "Could not locate prelude file"
        end
      end
    end

    # Create a new interpreter with an empty stack as it's top
    def self.new
      self.new(Scope.new)
    end

    # Executes *program* inside *scope*
    def exec_program(program : Program, scope : Scope = @top)
      context = Context.new(program)
      exec_block(program.tree, scope, context)
    end

    private def exec_block(block : Block, scope : Scope, context : Context)
      last_result = TNull.new
      block.children.each do |statement|
        last_result = exec_expression(statement, scope, context)
      end
      last_result
    end

    private def exec_expression(node : ASTNode, scope : Scope, context : Context)

      case node
      when .is_a?(VariableInitialisation), .is_a?(ConstantInitialisation)

        # Check if the current scope already contains such a value
        if scope.contains(node.identifier.name)
          raise RunTimeError.new(node, context, "#{node.identifier.name} is already defined")
        end

        # Resolve the expression
        expression = exec_expression(node.expression, scope, context)

        # Check if we have to assign a constant or not
        if node.is_a? VariableInitialisation
          scope.write(node.identifier.name, expression, Flag::INIT)
        else
          scope.write(node.identifier.name, expression, Flag::INIT | Flag::CONSTANT)
        end

        return expression
      when .is_a? NumericLiteral
        return TNumeric.new(node.value.to_f64)
      when .is_a? NullLiteral
        return TNull.new
      end

      # Catch unknown nodes
      raise RunTimeError.new(node, context, "Unexpected node #{node.class.name.split("::").last}")
    end
  end
end
