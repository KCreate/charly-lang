require "../program.cr"
require "../syntax/parser.cr"
require "./container.cr"
require "./types.cr"
require "./context.cr"
require "./internals.cr"

module Charly
  include AST

  # The path at which the prelude is located
  PRELUDE_PATH = File.real_path(ENV["CHARLYDIR"] + "/src/std/prelude.ch")

  alias Scope = Container(BaseType)

  # Single trace entry for callstacks
  private class Trace
    property name : String
    property node : ASTNode

    def initialize(@name, @node)
    end

    def to_s(io)
      filename = File.basename(@node.location_start.filename)
      io << "at #{@name} (#{filename}:"
      io << @node.location_start.to_s.split(":").last(3).join(":")
      io << ")"
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

  # An exception as thrown by the user
  private class UserException < Exception
    property payload : BaseType
    property trace : Array(Trace)
    property origin : ASTNode
    property context : Context

    def initialize(@payload, @trace, @origin, @context)
    end

    def to_s(io)
      payload = @payload

      message = "Uncaught #{payload}"

      if payload.is_a?(DataType) && payload.data.contains "message"
        message += ": #{payload.data.get("message").to_s}"
      end

      io << RunTimeError.new(@origin, @context, message)
    end
  end

  # The interpreter takes a Program instance and executes the tree recursively.
  class Visitor
    property top : Scope
    property prelude : Scope
    property trace : Array(Trace) # The leftmost value is the main trace entry

    # A list of disallowed variable names
    DISALLOWED_VARS = [
      "self",
      "__internal__method"
    ]

    # Mapping between types and their class names
    CLASS_MAPPING = {
      TObject => "Object",
      TClass => "Class",
      TPrimitiveClass => "Class",
      TNumeric => "Numeric",
      TString => "String",
      TBoolean => "Boolean",
      TArray => "Array",
      TFunc => "Function",
      TInternalFunc => "Function",
      TNull => "Null"
    }

    # Mapping between operators and function names you use to override them
    OPERATOR_MAPPING = {

      # Arithmetic
      TokenType::Plus => "__plus",
      TokenType::Minus => "__minus",
      TokenType::Mult => "__mult",
      TokenType::Divd => "__divd",
      TokenType::Mod => "__mod",
      TokenType::Pow => "__pow",

      # Comparison
      TokenType::Less => "__less",
      TokenType::Greater => "__greater",
      TokenType::LessEqual => "__lessequal",
      TokenType::GreaterEqual => "__greaterequal",
      TokenType::Equal => "__equal",
      TokenType::Not => "__not"
    }

    # Mapping between unary operators and function names you use to override them
    UNARY_OPERATOR_MAPPING = {
      TokenType::Plus => "__uplus",
      TokenType::Minus => "__uminus",
      TokenType::Not => "__unot"
    }

    # Creates a new Interpreter inside *top*
    # Setting *load_prelude* to false will prevent loading the prelude file
    def initialize(@top : Scope, @prelude)
      @trace = [] of Trace
    end

    # Create a new interpreter with an empty scope as it's top
    def self.new
      prelude = Scope.new
      user = Scope.new(prelude)

      self.new(user, prelude)
    end

    # :nodoc:
    def render_trace(io)
      @trace.reverse.each do |entry|
        io << entry
        io << '\n'
      end
    end

    # Executes *program* inside *scope*
    def exec_program(program : Program, scope : Scope = @top)

      # Insert *export* if not already set
      unless scope.contains "export"
        scope.write("export", TObject.new, Flag::INIT)
      end

      unless scope.contains "self"
        self_object = TObject.new
        self_object.data = scope
        scope.write("self", self_object, Flag::INIT | Flag::CONSTANT)
      end

      context = Context.new(program, @trace)
      exec_block(program.tree, scope, context)
    end

    private def exec_block(block : Block, scope, context)
      last_result = TNull.new
      block.each do |statement|
        last_result = exec_expression(statement, scope, context)
      end
      last_result
    end

    private def exec_expression(node : ASTNode | BaseType, scope, context)

      case node
      when .is_a? BaseType
        return node
      when .is_a?(VariableInitialisation), .is_a?(ConstantInitialisation)
        return exec_initialisation(node, scope, context)
      when .is_a? VariableAssignment
        return exec_assignment(node, scope, context)
      when .is_a? UnaryExpression
        return exec_unary_expression(node, scope, context)
      when .is_a? BinaryExpression
        return exec_binary_expression(node, scope, context)
      when .is_a? ComparisonExpression
        return exec_comparison_expression(node, scope, context)
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
      when .is_a? PrimitiveClassLiteral
        return exec_primitive_class_literal(node, scope, context)
      when .is_a? ContainerLiteral
        return exec_container_literal(node, scope, context)
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
        left_value = exec_expression(node.left, scope, context)
        left = exec_get_truthyness(left_value, scope, context)

        if left
          return left_value
        else
          return exec_expression(node.right, scope, context)
        end
      when .is_a? MemberExpression
        return exec_member_expression(node, scope, context)
      when .is_a? IndexExpression
        return exec_index_expression(node, scope, context)
      when .is_a? TryCatchStatement
        return exec_try_catch_statement(node, scope, context)
      when .is_a? ThrowStatement
        return exec_throw_statement(node, scope, context)
      end

      # Catch unknown nodes
      raise RunTimeError.new(node, context, "Unexpected node #{node.class.name.split("::").last}")
    end

    private def exec_initialisation(node : ASTNode, scope, context)

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

      # If the expression is a TFunc and it doesn't have a name yet, give it a name
      if expression.is_a? TFunc
        unless expression.name.is_a? String
          expression.name = node.identifier.name
        end
      end

      # Check if we have to assign a constant or not
      if node.is_a? VariableInitialisation
        scope.write(node.identifier.name, expression, Flag::INIT)
      else
        scope.write(node.identifier.name, expression, Flag::INIT | Flag::CONSTANT)
      end

      return expression
    end

    private def exec_assignment(node : VariableAssignment, scope, context)

      # Resolve the expression
      expression = exec_expression(node.expression, scope, context)

      # Check the type of the assignment
      case (identifier = node.identifier)
      when IdentifierLiteral

        # Check if the identifier name is disallowed
        if DISALLOWED_VARS.includes? identifier.name
          raise RunTimeError.new(node, context, "#{identifier.name} is a reserved keyword")
        end

        # Check if the identifier exists
        unless scope.defined identifier.name
          raise RunTimeError.new(identifier, context, "#{identifier.name} is not defined")
        end

        # Check if the identifier is a constant
        if scope.get_reference(identifier.name).is_constant
          raise RunTimeError.new(identifier, context, "#{identifier.name} is a constant")
        end

        # Write to the scope
        scope.write(identifier.name, expression, Flag::None)
        return expression
      when MemberExpression

        # Manually resolve the member expression
        member = identifier.member
        identifier = identifier.identifier

        # Resolve the identifier
        _identifier = exec_expression(identifier, scope, context)

        # Write to the data field of the value
        if _identifier.is_a?(DataType)
          if _identifier.data.contains(member.name)
            _identifier.data.write(member.name, expression, Flag::None)
          else
            _identifier.data.write(member.name, expression, Flag::INIT)
          end
        else
          raise RunTimeError.new(identifier, context, "Can't write to non-object")
        end

        return expression
      when IndexExpression

        # Manually resolve the index expression
        argument = identifier.argument
        identifier = identifier.identifier

        # Resolve the identifier
        target = exec_expression(identifier, scope, context)

        # Resolve the argument
        argument = exec_expression(argument, scope, context)

        case target
        when .is_a? TArray

          # Typecheck the argument
          unless argument.is_a? TNumeric
            raise RunTimeError.new(identifier, context, "Expected number, got #{target.class}")
          end

          # Out of bounds check
          if argument.value < 0 || argument.value > target.value.size - 1
            raise RunTimeError.new(identifier, context, "Index out of bounds. Size is #{target.value.size}, index is #{argument.value}")
          end

          # Write to the index
          target.value[argument.value.to_i64] = expression
          return expression
        when .is_a? TObject

          # Typecheck the argument
          unless argument.is_a? TString
            raise RunTimeError.new(identifier, context, "Expected string, got #{target.class}")
          end

          if target.data.contains(argument.value)
            target.data.write(argument.value, expression, Flag::None)
          else
            target.data.write(argument.value, expression, Flag::INIT)
          end
        else
          raise RunTimeError.new(identifier, context, "Expected array or object, got #{target.class}")
        end
      else
        raise RunTimeError.new(identifier, context, "Invalid left-hand-side of assignment")
      end
    end

    private def exec_unary_expression(node : UnaryExpression, scope, context)

      # Resolve the right side
      operator = node.operator
      right = exec_expression(node.right, scope, context)

      override_method_name = UNARY_OPERATOR_MAPPING[operator]

      # Check if the data of the value contains this method
      # If it doesn't check if the primitive class has an entry for it
      method = nil
      if right.is_a?(DataType) && right.data.contains override_method_name
        method = right.data.get(override_method_name, Flag::IGNORE_PARENT)
      elsif right.is_a? TArray
        method = get_primitive_method(right, override_method_name, scope, context)
      end

      if method.is_a? TFunc

        # Create a fake call expression
        callex = CallExpression.new(
          MemberExpression.new(
            node.right,
            IdentifierLiteral.new("#{operator}").at(node.right)
          ).at(node.right),
          ExpressionList.new([] of ASTNode).at(node.right)
        ).at(node)

        return exec_function_call(method, callex, right, scope, context)
      end

      case node.operator
      when TokenType::Plus
        return right
      when TokenType::Minus
        if right.is_a? TNumeric
          return TNumeric.new(-right.value)
        end
      when TokenType::Not
        return TBoolean.new(!exec_get_truthyness(right, scope, context))
      end

      return TNull.new
    end

    private def exec_binary_expression(node : BinaryExpression, scope, context)

      # Resolve the left side
      operator = node.operator
      left = exec_expression(node.left, scope, context)

      override_method_name = OPERATOR_MAPPING[operator]

      # Check if the data of the value contains this method
      # If it doesn't check if the primitive class has an entry for it
      method = nil
      if left.is_a?(DataType) && left.data.contains override_method_name
        method = left.data.get(override_method_name, Flag::IGNORE_PARENT)
      elsif left.is_a? TArray
        method = get_primitive_method(left, override_method_name, scope, context)
      end

      if method.is_a? TFunc

        # Create a fake call expression
        callex = CallExpression.new(
          MemberExpression.new(
            node.left,
            IdentifierLiteral.new("#{operator}").at(node.left)
          ).at(node.left),
          ExpressionList.new([
            node.right
          ] of ASTNode).at(node.right)
        ).at(node)

        return exec_function_call(method, callex, left, scope, context)
      end

      # No primitive method was found
      right = exec_expression(node.right, scope, context)

      if left.is_a?(TNumeric) && right.is_a?(TNumeric)
        case operator
        when TokenType::Plus
          return TNumeric.new(left.value + right.value)
        when TokenType::Minus
          return TNumeric.new(left.value - right.value)
        when TokenType::Mult
          if left.value == 0 || right.value == 0
            return TNumeric.new(0)
          end
          return TNumeric.new(left.value * right.value)
        when TokenType::Divd
          if left.value == 0 || right.value == 0
            return TNumeric.new(Float64::NAN)
          end
          return TNumeric.new(left.value / right.value)
        when TokenType::Mod
          if right.value == 0
            return TNumeric.new(Float64::NAN)
          end
          return TNumeric.new(left.value.to_i64 % right.value.to_i64)
        when TokenType::Pow
          return TNumeric.new(left.value ** right.value)
        end
      end

      if left.is_a?(TString) && right.is_a?(TString)
        case operator
        when TokenType::Plus
          return TString.new("#{left}#{right}")
        end
      end

      if left.is_a?(TString) && !right.is_a?(TString)
        case operator
        when TokenType::Plus

          # Check if the right expression has a to_s method
          if right.is_a?(DataType) && right.data.contains("to_s")
            entry = right.data.get("to_s")

            if entry.is_a? TFunc

              # Create a fake call expression
              callex = CallExpression.new(
                MemberExpression.new(
                  node.right,
                  IdentifierLiteral.new("#{to_s}").at(node.right)
                ).at(node.right),
                ExpressionList.new([] of ASTNode).at(node.right)
              ).at(node.right)

              right_string = exec_function_call(entry, callex, right, scope, context)
              return TString.new("#{left}#{right_string}")
            end
          end

          return TString.new("#{left}#{right}")
        when TokenType::Mult

          # Check if the right side is a TNumeric
          if right.is_a?(TNumeric)
            return TString.new(left.value * right.value.to_i64)
          end
        end
      end

      if !left.is_a?(TString) && right.is_a?(TString)
        case operator
        when TokenType::Plus

          # Check if the right expression has a to_s method
          if right.is_a?(DataType) && right.data.contains("to_s")
            entry = right.data.get("to_s")

            if entry.is_a? TFunc

              # Create a fake call expression
              callex = CallExpression.new(
                MemberExpression.new(
                  node.right,
                  IdentifierLiteral.new("#{to_s}").at(node.right)
                ).at(node.right),
                ExpressionList.new([] of ASTNode).at(node.right)
              ).at(node.right)

              right_string = exec_function_call(entry, callex, right, scope, context)
              return TString.new("#{left}#{right_string}")
            end
          end

          return TString.new("#{left}#{right}")
        when TokenType::Mult

          # Check if the left side is a TNumeric
          if left.is_a?(TNumeric)
            return TString.new(right.value * left.value.to_i64)
          end
        end
      end

      return TNumeric.new(Float64::NAN)
    end

    private def exec_comparison_expression(node : ComparisonExpression, scope, context)

      # Resolve the left side
      operator = node.operator
      left = exec_expression(node.left, scope, context)

      override_method_name = OPERATOR_MAPPING[operator]

      # Check if the data of the value contains this method
      # If it doesn't check if the primitive class has an entry for it
      method = nil
      if left.is_a?(DataType) && left.data.contains override_method_name
        method = left.data.get(override_method_name, Flag::IGNORE_PARENT)
      elsif left.is_a? TArray
        method = get_primitive_method(left, override_method_name, scope, context)
      end

      if method.is_a? TFunc

        # Create a fake call expression
        callex = CallExpression.new(
          MemberExpression.new(
            node.left,
            IdentifierLiteral.new("#{operator}").at(node.left)
          ).at(node.left),
          ExpressionList.new([
            node.right
          ] of ASTNode).at(node.right)
        ).at(node)

        return exec_function_call(method, callex, left, scope, context)
      end

      # No primitive method was found
      right = exec_expression(node.right, scope, context)

      # When comparing TNumeric's
      if left.is_a?(TNumeric) && right.is_a?(TNumeric)

        # Different types of operators
        case operator
        when TokenType::Greater
          return TBoolean.new(left.value > right.value)
        when TokenType::Less
          return TBoolean.new(left.value < right.value)
        when TokenType::GreaterEqual
          return TBoolean.new(left.value >= right.value)
        when TokenType::LessEqual
          return TBoolean.new(left.value <= right.value)
        when TokenType::Equal
          if left.value.nan? && right.value.nan?
            return TBoolean.new(true)
          else
            return TBoolean.new(left.value == right.value)
          end
        when TokenType::Not
          return TBoolean.new(left.value != right.value)
        end
      end

      # When comparing TBools
      if left.is_a?(TBoolean) && right.is_a?(TBoolean)
        case operator
        when TokenType::Equal
          return TBoolean.new(left.value == right.value)
        when TokenType::Not
          return TBoolean.new(left.value != right.value)
        end
      end

      # When comparing strings
      if left.is_a?(TString) && right.is_a?(TString)
        case operator
        when TokenType::Greater
          return TBoolean.new(left.value.size > right.value.size)
        when TokenType::Less
          return TBoolean.new(left.value.size < right.value.size)
        when TokenType::GreaterEqual
          return TBoolean.new(left.value.size >= right.value.size)
        when TokenType::LessEqual
          return TBoolean.new(left.value.size <= right.value.size)
        when TokenType::Equal
          return TBoolean.new(left.value == right.value)
        when TokenType::Not
          return TBoolean.new(left.value != right.value)
        end
      end

      # When comparing TFunc
      if left.is_a?(TFunc) && right.is_a?(TFunc)
        case operator
        when TokenType::Equal
          return TBoolean.new(left == right)
        when TokenType::Not
          return TBoolean.new(left != right)
        end
      end

      # When comparing TClass
      if left.is_a?(TClass) && right.is_a?(TClass)
        case operator
        when TokenType::Equal
          return TBoolean.new(left == right)
        when TokenType::Not
          return TBoolean.new(left != right)
        end
      end

      # When comparing TPrimitiveClass
      if left.is_a?(TPrimitiveClass) && right.is_a?(TPrimitiveClass)
        case operator
        when TokenType::Equal
          return TBoolean.new(left == right)
        when TokenType::Not
          return TBoolean.new(left != right)
        end
      end

      # When comparing TObject
      if left.is_a?(TObject) && right.is_a?(TObject)
        case operator
        when TokenType::Equal
          return TBoolean.new(left == right)
        when TokenType::Not
          return TBoolean.new(left != right)
        end
      end

      if left.is_a? TNull

        case operator
        when TokenType::Equal

          if right.is_a? TBoolean
            return TBoolean.new(!right.value)
          end

          return TBoolean.new(right.is_a? TNull)
        when TokenType::Not

          if right.is_a? TBoolean
            return TBoolean.new(right.value)
          end

          return TBoolean.new(!right.is_a?(TNull))
        end
      end

      if right.is_a? TNull
        case operator
        when TokenType::Equal

          if left.is_a? TBoolean
            return TBoolean.new(left.value)
          end

          return TBoolean.new(left.is_a? TNull)
        when TokenType::Not

          if left.is_a? TBoolean
            return TBoolean.new(!left.value)
          end

          return TBoolean.new(!left.is_a?(TNull))
        end
      end

      # If the left side is bool
      if left.is_a?(TBoolean) && !right.is_a?(TBoolean)
        case operator
        when TokenType::Equal
          return TBoolean.new(left.value == exec_get_truthyness(right, scope, context))
        when TokenType::Not
          return TBoolean.new(left.value != exec_get_truthyness(right, scope, context))
        end
      end

      if !left.is_a?(TBoolean) && right.is_a?(TBoolean)
        case operator
        when TokenType::Equal
          return TBoolean.new(right.value == exec_get_truthyness(left, scope, context))
        when TokenType::Not
          return TBoolean.new(right.value != exec_get_truthyness(left, scope, context))
        end
      end

      return TBoolean.new(false)
    end

    private def exec_array_literal(node : ArrayLiteral, scope, context)
      content = [] of BaseType

      node.each do |item|
        content << exec_expression(item, scope, context)
      end

      return TArray.new(content)
    end

    private def exec_function_literal(node : FunctionLiteral, scope, context)
      TFunc.new(
        node.name,
        node.argumentlist,
        node.block,
        scope
      ).tap do |func|
        func.data.replace("name", TString.new(node.name || ""), Flag::INIT)
      end
    end

    private def exec_class_literal(node : ClassLiteral, scope, context)

      # Check if parent classes exist
      parents = [] of TClass
      node.parents.each do |parent|

        # Sanity check
        unless parent.is_a? IdentifierLiteral
          raise RunTimeError.new(parent, context, "Node is not an identifier. You've found a bug in the interpreter.")
        end

        # Check if the variable name is allowed
        if DISALLOWED_VARS.includes? parent.name
          raise RunTimeError.new(parent, context, "#{parent.name} is a reserved keyword")
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

      # Extract properties and methods
      class_scope = Scope.new(scope)
      properties = [] of IdentifierLiteral
      methods = [] of FunctionLiteral

      # Extract parent methods and properties
      parents.each do |parent|
        parent.data.dump_values(false).each do |depth, key, value, flags|
          class_scope.write(key, value, Flag::INIT | Flag::CONSTANT)
        end
      end

      node.block.each do |child|
        case child
        when .is_a? PropertyDeclaration
          properties << child.identifier
        when .is_a? FunctionLiteral
          if child.name.is_a? String
            methods << child
          end
        when .is_a? StaticDeclaration
          value = child.node
          case value
          when .is_a? PropertyDeclaration

            # Check if the property is already defined
            if class_scope.contains value.identifier.name
              class_scope.write(value.identifier.name, TNull.new, Flag::None)
            else
              class_scope.write(value.identifier.name, TNull.new, Flag::INIT)
            end
          when .is_a? FunctionLiteral
            method = exec_function_literal(value, class_scope, context)

            # Make sure the method has a name
            unless (name = method.name).is_a? String
              raise RunTimeError.new(value, context, "Missing method name")
            end

            # Check if the method is already defined
            if class_scope.contains name
              class_scope.write(name, method, Flag::None)
            else
              class_scope.write(name, method, Flag::INIT)
            end
          else
            raise RunTimeError.new(child, context, "Unallowed #{value.class.name}")
          end
        else
          raise RunTimeError.new(child, context, "Unallowed #{child.class.name}")
        end
      end

      return TClass.new(
        node.name,
        properties,
        methods,
        parents,
        scope
      ).tap { |klass|
        klass.data = class_scope
        klass.data.replace("name", TString.new(node.name), Flag::INIT | Flag::CONSTANT | Flag::IGNORE_PARENT)
      }
    end

    private def exec_primitive_class_literal(node : PrimitiveClassLiteral, scope, context)

      # The scope in which we run
      scope = Scope.new(scope)

      # Extract methods of the primitive class
      primscope = Scope.new(scope)
      methods = [] of TFunc

      # Check if a class called Object is defined
      if scope.defined("Object")
        entry = scope.get("Object")
        if entry.is_a? TClass
          get_class_methods(entry, context).each do |method|
            methods << method
          end
        end
      end

      # Append the primitive classes own methods
      node.block.each do |statement|
        case statement
        when .is_a? FunctionLiteral
          methods << exec_function_literal(statement, scope, context)
        when .is_a? PropertyDeclaration
          raise RunTimeError.new(statement, context, "Primitive classes can't have instance properties")
        when .is_a? StaticDeclaration
          case stat_node = statement.node
          when .is_a? FunctionLiteral
            method = exec_function_literal(stat_node, scope, context)
            primscope.write(method.name || "", method, Flag::INIT)
          when .is_a? PropertyDeclaration
            primscope.write(stat_node.identifier.name, TNull.new, Flag::INIT)
          end
        end
      end

      # Setup the primitive class and scope
      method_scope = Scope.new(scope)
      primclass = TPrimitiveClass.new(node.name, method_scope, scope)
      primclass.data.write("name", TString.new(node.name), Flag::INIT | Flag::CONSTANT)
      primclass.data = primscope

      # Reverse to use correct precedence
      methods.reverse!

      # Insert the methods
      methods.each do |method|
        if (name = method.name).is_a? String
          unless primscope.contains(name)
            method_scope.write(name, method, Flag::INIT | Flag::CONSTANT)
          end
        end
      end

      return primclass
    end

    private def exec_call_expression(node : CallExpression, scope, context)

      # If the identifier is a IdentifierLiteral we check if it is "__internal__method"
      # Similarly if the identifier is a member expression, we need that to resolve that seperately too
      identifier = node.identifier
      case identifier
      when .is_a? MemberExpression
        identifier, target = exec_get_member_expression_pairs(identifier, scope, context)
      when .is_a?(IdentifierLiteral)
        unless identifier.name == "__internal__method"
          identifier = nil
          target = exec_expression(node.identifier, scope, context)
        else

          # Resolve all arguments
          arguments = [] of BaseType
          node.argumentlist.each do |expression|
            arguments << exec_expression(expression, scope, context)
          end

          # Check if at least 1 argument is given
          unless arguments.size > 0
            raise RunTimeError.new(node, context, "Calls to __internal__method require at least 1 argument that acts as the method name")
          end

          # Check that the first argument is a string
          name = arguments[0]
          unless name.is_a? TString
            raise RunTimeError.new(node.argumentlist.children[0], context, "Calls to __internal__method require the first argument to be a string, got #{name.class}")
          end

          # Check if the method exists
          unless Internals::METHODS.has_key? name.value
            raise RunTimeError.new(node.argumentlist.children[0], context, "__internal__method doesn't know this method")
          end

          # Create the mapping between the methods
          method = Internals::METHODS[name.value]

          if method.is_a? InternalFuncType
            return TInternalFunc.new(name.value, method)
          end

          raise RunTimeError.new(node, context, "Failed to extract internal function #{name.value}")
        end
      when .is_a? IndexExpression
        identifier, target = exec_get_index_expression_pairs(identifier, scope, context)
      else
        identifier = nil
        target = exec_expression(node.identifier, scope, context)
      end

      if target.is_a? TFunc
        return exec_function_call(target, node, identifier, scope, context)
      elsif target.is_a? TInternalFunc

        # Resolve the arguments
        arguments = [] of BaseType
        node.argumentlist.each do |expression|
          arguments << exec_expression(expression, scope, context)
        end

        start = Time.now.epoch_ms
        result = target.method.call(node, self, scope, context, arguments.size, arguments)

        return result
      elsif target.is_a? TClass
        return exec_class_call(target, node, scope, context)
      elsif target.is_a? TPrimitiveClass
        raise RunTimeError.new(node.identifier, context, "Can't instantiate primitive class #{target}")
      else
        raise RunTimeError.new(node.identifier, context, "Not a function or class")
      end
    end

    private def exec_function_call(target : TFunc, node : CallExpression, identifier : BaseType?, scope, context)

      # The scope in which the function will run
      function_scope = Scope.new(target.parent_scope)

      # Check if enough arguments were supplied
      if node.argumentlist.size < target.argumentlist.size
        if target.argumentlist.size == 1
          error_message = "Method expected 1 argument, got #{node.argumentlist.size}"
        else
          error_message = "Method expected #{target.argumentlist.size} arguments, got #{node.argumentlist.size}"
        end

        raise RunTimeError.new(
          node.identifier,
          context,
          error_message
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
        i += 1
      end

      # If an identifier is given, assign it to the self keyword
      if identifier.is_a? BaseType
        function_scope.write("self", identifier, Flag::INIT | Flag::CONSTANT)
      end

      # Insert the arguments
      unless function_scope.contains("arguments")
        function_scope.write("arguments", TArray.new(arguments), Flag::INIT)
      end

      # Execute the functions block inside the function_scope
      @trace << Trace.new("#{target.name || "anonymous"}", node)
      begin
        result = exec_block(target.block, function_scope, context)
      rescue e : ReturnException
        result = e.payload
      end
      @trace.pop

      return result
    end

    private def exec_class_call(target : TClass, node : CallExpression, scope, context)

      # Initialize an empty object
      object = TObject.new(target)
      object_scope = Scope.new(target.parent_scope)
      object.data = object_scope
      object_scope.write("type", target, Flag::INIT | Flag::CONSTANT)

      # The properties the method needs
      properties = get_class_props(target)

      # The methods are reversed to make sure we obtain methods in the correct precedence
      # Parent methods are loaded first
      methods = get_class_methods(target, context).reverse

      # Register the properties
      properties.each do |prop|
        object_scope.write(prop, TNull.new, Flag::INIT)
      end

      # Run the first constructor we can find
      constructor = nil
      methods.each do |method|

        # Functions without names are filtered out when the class is set up
        # We still have to check because it could technically be nil
        name = method.name
        if name.is_a? String
          # Check if such a method was already registered
          unless object_scope.contains(name, Flag::IGNORE_PARENT)
            object_scope.write(name, method, Flag::INIT | Flag::CONSTANT)

            if name == "constructor"
              constructor = method
            end
          end
        end
      end

      # Search for a constructor function and execute
      if constructor.is_a?(TFunc)

        # Remove the constuctor again
        object_scope.delete("constructor", Flag::IGNORE_PARENT)

        # Create a fake call expression containing the arguments from the original expression
        callex = CallExpression.new(
          IdentifierLiteral.new("constructor").at(node.identifier.location_start),
          node.argumentlist
        ).at(node.location_start, node.location_end)

        # Execute the constructor function inside the object_scope
        @trace << Trace.new("#{target.name}:constructor", node)
        exec_function_call(constructor, callex, object, scope, context)
        @trace.pop
      end

      return object
    end

    private def get_class_props(target : TClass)
      properties = [] of String
      if target.parents.size > 0
        target.parents.each do |parent|
          get_class_props(parent).each do |prop|
            properties << prop
          end
        end
      end

      target.properties.each do |prop|
        properties << prop.name
      end

      properties
    end

    private def get_class_methods(target : TClass, context)
      methods = [] of TFunc
      if target.parents.size > 0
        target.parents.each do |parent|
          get_class_methods(parent, context).each do |method|
            methods << method
          end
        end
      end

      target.methods.each do |method|
        methods << exec_function_literal(method, target.parent_scope, context)
      end

      methods
    end

    private def exec_member_expression(node : MemberExpression, scope, context)
      return exec_get_member_expression_pairs(node, scope, context)[1]
    end

    private def exec_get_member_expression_pairs(node : MemberExpression, scope, context)

      # Resolve the left side
      identifier = exec_expression(node.identifier, scope, context)

      # Check if the member name is allowed
      if DISALLOWED_VARS.includes? node.member.name
        raise RunTimeError.new(node.member, context, "#{node.member.name} is a reserved keyword")
      end

      return exec_get_member_expression_pairs_via_name(identifier, node.member.name, scope, context)
    end

    private def exec_get_member_expression_pairs_via_name(identifier : BaseType, member : String, scope, context)

      # Check if the member name is allowed
      if DISALLOWED_VARS.includes? member
        raise Exception.new("#{member} is not allowed as a member name. This error message doesn't have a location associated with it because of the way it is imlpemented internally")
      end

      # Check if the value contains the key that's asked for
      if identifier.is_a?(DataType) && identifier.data.contains member
        return ({identifier, identifier.data.get(member, Flag::IGNORE_PARENT)})
      else
        method = get_primitive_method(identifier, member, scope, context)

        if method.is_a? BaseType
          return ({ identifier, method })
        end
      end

      return ({ identifier, TNull.new })
    end

    private def exec_index_expression(node : IndexExpression, scope, context)
      return exec_get_index_expression_pairs(node, scope, context)[1]
    end

    private def exec_get_index_expression_pairs(node : IndexExpression, scope, context)

      # Resolve the left side
      identifier = exec_expression(node.identifier, scope, context)

      # Resolve the argument
      argument = exec_expression(node.argument, scope, context)

      # Check if the left side is an array or a string
      case identifier
      when .is_a? TArray

        # Check that the first argument is a numeric
        unless argument.is_a? TNumeric
          raise RunTimeError.new(node.argument, context, "Expected numeric, got #{argument.class}")
        end

        # Check for out-of-bounds errors
        argument = argument.value.to_i64
        if argument > identifier.value.size - 1 || argument < 0
          return ({ identifier, TNull.new })
        end

        return ({ identifier, identifier.value[argument] })
      when .is_a? TString

        # Check that the first argument is a numeric
        unless argument.is_a? TNumeric
          raise RunTimeError.new(node.argument, context, "Expected numeric, got #{argument.class}")
        end

        # Check for out-of-bounds errors
        argument = argument.value.to_i64
        if argument > identifier.value.size - 1 || argument < 0
          return ({ identifier, TNull.new })
        end

        return ({ identifier, TString.new(identifier.value[argument].to_s) })
      when .is_a? TObject

        # Check that the first argument is a string
        unless argument.is_a? TString
          raise RunTimeError.new(node.argument, context, "Expected string, got #{argument.class}")
        end

        return exec_get_member_expression_pairs_via_name(identifier, argument.value, scope, context)
      else
        raise RunTimeError.new(node, context, "Expected left side to be an array or string. Got: #{identifier.class}")
      end
    end

    private def get_primitive_method(type : BaseType, methodname : String, scope, context)
      get_primitive_method(type.class, methodname, scope, context)
    end

    private def get_primitive_method(type, methodname, scope, context)

      # This is defined in CLASS_MAPPING
      classname = CLASS_MAPPING[type]
      entry = scope.get(classname)

      if entry.is_a? TPrimitiveClass

        # Check if this class contains the given method
        if entry.methods.contains(methodname)
          return entry.methods.get(methodname, Flag::IGNORE_PARENT)
        end

        entry = scope.get("Object")

        # Check if this class contains the given method
        if entry.is_a?(TPrimitiveClass) && entry.methods.contains(methodname)
          prop = entry.methods.get(methodname, Flag::IGNORE_PARENT)

          if prop.is_a? BaseType
            return prop
          end
        end
      end

      return TNull.new
    end

    private def exec_if_statement(node : IfStatement, scope, context)

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

    private def exec_while_statement(node : WhileStatement, scope, context)

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

    private def exec_container_literal(node : ContainerLiteral, scope, context)

      # Create the object
      object = TObject.new
      object_data = Scope.new(scope)
      object.data = object_data

      # Insert the self keyword
      object_data.write("self", object, Flag::INIT | Flag::CONSTANT)

      # Run the block inside the scope
      exec_block(node.block, object_data, context)
      return object
    end

    private def exec_get_truthyness(value : BaseType, scope, context)
      case value
      when .is_a? TBoolean
        return value.value
      when .is_a? TNull
        return false
      else
        return true
      end
    end

    private def exec_try_catch_statement(node : TryCatchStatement, scope, context)
      scope = Scope.new(scope)
      trace_position = context.trace.size

      begin
        return exec_block(node.try_block, scope, context)
      rescue e : UserException

        # Reset the trace position
        context.trace.delete_at(trace_position..-1)

        scope.write(node.exception_name.name, e.payload, Flag::INIT)
        return exec_block(node.catch_block, scope, context)
      rescue e : RunTimeError | SyntaxError

        # Extract the trace entries
        trace_entries = [] of BaseType
        context.trace.map { |entry|
          trace_entries << TString.new(entry.to_s)
        }

        # Reset the trace position
        context.trace.delete_at(trace_position..-1)

        # Create the exception object
        exc = TObject.new
        exc.data = Scope.new
        exc.data.write("message", TString.new(e.message || "RunTimeError"), Flag::INIT)
        exc.data.write("trace", TArray.new(trace_entries), Flag::INIT)

        # Insert into the catch block
        scope.write(node.exception_name.name, exc, Flag::INIT)
        return exec_block(node.catch_block, scope, context)
      end
    end

    private def exec_throw_statement(node : ThrowStatement, scope, context)
      expression = exec_expression(node.expression, scope, context)
      raise UserException.new(expression, @trace.dup, node, context)
    end
  end
end
