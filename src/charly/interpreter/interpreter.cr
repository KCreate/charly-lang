require "../program.cr"
require "../syntax/parser.cr"
require "./container.cr"
require "./types.cr"

module Charly
  include AST

  alias Scope = Container(BaseType)

  # Single trace entry for callstacks
  struct Trace
    property name : String
    property node : ASTNode
    property context : Scope

    def initialize(@name, @node, @context)
    end
  end

  # The interpreter takes a Program instance and executes the tree recursively.
  class Interpreter
    property context : Scope
    property trace : Array(Trace)
    property program : Program?

    # Creates a new Interpreter inside *context*
    # Setting *load_prelude* to false will prevent loading the prelude file
    def initialize(@context : Scope, load_prelude : Bool = true)
      @trace = [] of Trace

      # Load the prelude if *load_prelude* is set to true
      if load_prelude

        # Check if the prelude exists
        prelude_path = File.real_path(ENV["CHARLYDIR"] + "/src/std/prelude.charly")
        if File.readable?(prelude_path)
          program = Parser.create(File.open(prelude_path), prelude_path)
          exec_program(program, @context)
        else
          raise IOException.new "Could not locate prelude file"
        end
      end
    end

    # Create a new interpreter with an empty stack as it's context
    def self.new
      self.new(Scope.new)
    end

    # Executes *program* inside *scope*
    def exec_program(program : Program, scope : Scope = @context)
      @program = program
      exec_block(program.tree, scope)
    end

    private def exec_block(block : Block, scope : Scope)
      last_result = TNull.new
      block.children.each do |statement|
        last_result = exec_expression(statement, scope)
      end
      last_result
    end

    private def exec_expression(node : ASTNode, scope : Scope)
      raise InvalidNode.new(
        node.location_start,
        node.location_end,
        @program.not_nil!.source,
        "Unexpected node #{node.class.name}"
      )
    end
  end
end
