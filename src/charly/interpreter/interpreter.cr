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

  # Exception used to return prematurely from functions
  private class ReturnException < Exception
    property payload : BaseType

    def initialize(@payload)
    end
  end

  # Exception used to return prematurely from while loops
  private class BreakException < Exception
  end

  # The interpreter takes a Program instance and executes the tree recursively.
  class Interpreter
    property top : Scope
    property trace : Array(Trace)

    # A list of disallowed variable names
    DISALLOWED_VARS = [
      "self"
    ]

    # The path at which the prelude is saved
    PRELUDE_PATH = File.real_path(ENV["CHARLYDIR"] + "/src/std/prelude.charly")

    # Creates a new Interpreter inside *top*
    # Setting *load_prelude* to false will prevent loading the prelude file
    def initialize(@top : Scope, load_prelude : Bool = true)
      @trace = [] of Trace

      # Load the prelude if *load_prelude* is set to true
      if load_prelude

        # Check if the prelude exists
        if File.readable?(PRELUDE_PATH)
          program = Parser.create(File.open(PRELUDE_PATH), PRELUDE_PATH)
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
      block.each do |statement|
        last_result = exec_expression(statement, scope, context)
      end
      last_result
    end

    private def exec_expression(node : ASTNode, scope : Scope, context : Context)

      case node
      when .is_a?(VariableInitialisation), .is_a?(ConstantInitialisation)
        return exec_initialisation(node, scope, context)
      when .is_a? VariableAssignment
        return exec_assignment(node, scope, context)
      when .is_a? IdentifierLiteral

        # Check if the identifier exists
        unless scope.defined(node.name)
          raise RunTimeError.new(node, context, "#{node.name} is not defined")
        end

        return scope.get(node.name)
      when .is_a? NumericLiteral
        return TNumeric.new(node.value.to_f64)
      when .is_a? StringLiteral
        return TString.new(node.value)
      when .is_a? BooleanLiteral
        return TBoolean.new(node.value)
      when .is_a? ArrayLiteral
        return exec_array_literal(node, scope, context)
      when .is_a? NullLiteral
        return TNull.new
      when .is_a? FunctionLiteral
        return exec_function_literal(node, scope, context)
      when .is_a? ClassLiteral
        return exec_class_literal(node, scope, context)
      when .is_a? CallExpression
        return exec_call_expression(node, scope, context)
      when .is_a? NANLiteral
        return TNumeric.new(Float64::NAN)
      when .is_a? ReturnStatement
        expression = exec_expression(node.expression, scope, context)
        raise ReturnException.new(expression)
      when .is_a? BreakStatement
        raise BreakException.new
      when .is_a? IfStatement
        return exec_if_statement(node, scope, context)
      when .is_a? WhileStatement
        return exec_while_statement(node, scope, context)
      when .is_a? And
        left = exec_get_truthyness(exec_expression(node.left, scope, context), scope, context)

        if left
          right = exec_get_truthyness(exec_expression(node.right, scope, context), scope, context)
          return TBoolean.new(right)
        else
          return TBoolean.new(false)
        end
      when .is_a? Or
        left = exec_get_truthyness(exec_expression(node.left, scope, context), scope, context)

        if left
          return TBoolean.new(true)
        else
          right = exec_get_truthyness(exec_expression(node.right, scope, context), scope, context)
          return TBoolean.new(right)
        end
      end

      # Catch unknown nodes
      raise RunTimeError.new(node, context, "Unexpected node #{node.class.name.split("::").last}")
    end

    @[AlwaysInline]
    private def exec_initialisation(node : ASTNode, scope : Scope, context : Context)

      # Check if this is a disallowed variable name
      if DISALLOWED_VARS.includes? node.identifier.name
        raise RunTimeError.new(node.identifier, context, "#{node.identifier.name} is a reserved keyword")
      end

      # Check if the current scope already contains such a value
      if scope.contains(node.identifier.name)
        raise RunTimeError.new(node.identifier, context, "#{node.identifier.name} is already defined")
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
    end

    @[AlwaysInline]
    private def exec_assignment(node : VariableAssignment, scope : Scope, context : Context)

      # Resolve the expression
      expression = exec_expression(node.expression, scope, context)

      # Check the type of the assignment
      case (identifier = node.identifier)
      when IdentifierLiteral

        # Check if the identifier name is disallowed
        if DISALLOWED_VARS.includes? identifier.name
          raise RunTimeError.new(node, context, "#{identifier.name} is a reserved key")
        end

        # Check if the identifier exists
        unless scope.defined identifier.name
          raise RunTimeError.new(node, context, "#{identifier.name} is not defined")
        end

        # Check if the identifier is a constant
        if scope.get_reference(identifier.name).is_constant
          raise RunTimeError.new(node, context, "#{identifier.name} is a constant")
        end

        # Write to the scope
        scope.write(identifier.name, expression, Flag::None)
        return expression
      when MemberExpression
        raise RunTimeError.new(node, context, "Member assignments are not implemented yet")
      when IndexExpression
        raise RunTimeError.new(node, context, "Index assignments are not implemented yet")
      end

      return TNull.new
    end

    @[AlwaysInline]
    private def exec_array_literal(node : ArrayLiteral, scope : Scope, context : Context)
      content = [] of BaseType

      node.each do |item|
        content << exec_expression(item, scope, context)
      end

      return TArray.new(content)
    end

    @[AlwaysInline]
    private def exec_function_literal(node : FunctionLiteral, scope : Scope, context : Context)
      TFunc.new(
        node.name,
        node.argumentlist,
        node.block,
        scope
      )
    end

    @[AlwaysInline]
    private def exec_class_literal(node : ClassLiteral, scope : Scope, context : Context)

      # Check if parent classes exist
      parents = [] of TClass
      node.parents.each do |parent|

        # Sanity check
        unless parent.is_a? IdentifierLiteral
          raise RunTimeError.new(parent, context, "Node is not an identifier. You've found a bug in the interpreter.")
        end

        # Check if the class is defined
        unless scope.defined parent.name
          raise RunTimeError.new(parent, context, "#{parent.name} is not defined")
        end

        value = scope.get(parent.name)

        unless value.is_a? TClass
          raise RunTimeError.new(parent, context, "#{parent.name} is not a class")
        end

        parents << value
      end

      return TClass.new(
        node.name,
        parents,
        node.block,
        scope
      )
    end

    @[AlwaysInline]
    private def exec_call_expression(node : CallExpression, scope : Scope, context : Context)

      # Resolve the identifier
      target = exec_expression(node.identifier, scope, context)

      if target.is_a? TFunc
        return exec_function_call(target, node, scope, context)
      else
        raise RunTimeError.new(node.identifier, context, "#{target} is not a function")
      end
    end

    @[AlwaysInline]
    private def exec_function_call(target : TFunc, node : CallExpression, scope : Scope, context : Context)

      # The scope in which the function will run
      function_scope = Scope.new(target.parent_scope)

      # Check if enough arguments were supplied
      if node.argumentlist.size < target.argumentlist.size
        raise RunTimeError.new(
          node.identifier,
          context,
          "Function expected #{target.argumentlist.size} arguments, got #{node.argumentlist.size}"
        )
      end

      # Resolve the arguments
      arguments = [] of BaseType
      node.argumentlist.each do |arg|
        arguments << exec_expression(arg, scope, context)
      end

      # Insert the arguments
      i = 0
      target.argumentlist.each do |arg|

        unless arg.is_a? IdentifierLiteral
          raise RunTimeError.new(arg, context, "#{arg} is not an identifier. You've found a bug in the interpreter.")
        end

        function_scope.write(arg.name, arguments[i], Flag::INIT)
        i += 0
      end

      # Execute the functions block inside the function_scope
      begin
        result = exec_block(target.block, function_scope, context)
      rescue e : ReturnException
        result = e.payload
      end

      # If the return value is a function
      # we keep the function_scope in tact to form a closure
      unless result.is_a? TFunc
        function_scope.finalize unless result.is_a? TFunc
      end

      return result
    end

    @[AlwaysInline]
    private def exec_if_statement(node : IfStatement, scope : Scope, context : Context)

      scope = Scope.new(scope)

      # Resolve the expression first
      test = exec_expression(node.test, scope, context)
      test = exec_get_truthyness(test, scope, context)

      if test
        return exec_block(node.consequent, scope, context)
      else
        alternate = node.alternate
        if alternate.is_a? IfStatement
          return exec_if_statement(alternate, scope, context)
        elsif alternate.is_a? Block
          return exec_block(alternate, scope, context)
        else
          return TNull.new
        end
      end
    end

    @[AlwaysInline]
    private def exec_while_statement(node : WhileStatement, scope : Scope, context : Context)

      scope = Scope.new(scope)

      # Resolve the expression first
      last_result = TNull.new
      while exec_get_truthyness(exec_expression(node.test, scope, context), scope, context)
        begin
          last_result = exec_block(node.consequent, scope, context)
        rescue e : BreakException
          break
        end
      end

      return last_result
    end

    @[AlwaysInline]
    private def exec_get_truthyness(value : BaseType, scope : Scope, context : Context)
      case value
      when .is_a? TBoolean
        return value.value
      when .is_a? TNull
        return false
      else
        return true
      end
    end
  end
end
