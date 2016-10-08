require "../syntax/ast/ast.cr"
require "./stack.cr"
require "./types.cr"
require "./internal-functions.cr"

# Execute the AST by recursively traversing it's nodes
class Interpreter
  include CharlyTypes
  property initial_stack : Stack
  property program_result : BaseType

  def initialize(programs, stack)
    @initial_stack = stack
    @program_result = exec_programs(programs, stack)
  end

  # Execute a bunch of programs, each having access to a shared top stack
  def exec_programs(programs, stack)
    last_result = TNull.new
    programs.map do |program|
      last_result = exec_program(program, stack)
    end
    last_result
  end

  # Executes *program* inside *stack*
  def exec_program(program, stack)
    exec_block(program.children[0], stack)
  end

  # Executes *node* inside *stack*
  def exec_block(node, stack)
    last_result = TNull.new
    node.children.each do |expression|
      last_result = exec_expression(expression, stack)
    end
    last_result
  end

  # Executes *node* inside *stack*
  def exec_expression(node, stack)

    if node.is_a? VariableDeclaration
      return exec_variable_declaration(node, stack)
    end

    if node.is_a? VariableInitialisation
      return exec_variable_initialisation(node, stack)
    end

    if node.is_a? VariableAssignment
      return exec_variable_assignment(node, stack)
    end

    if node.is_a? UnaryExpression
      return exec_unary_expression(node, stack)
    end

    if node.is_a? BinaryExpression
      return exec_binary_expression(node, stack)
    end

    if node.is_a? ComparisonExpression
      return exec_comparison_expression(node, stack)
    end

    if node.is_a? IdentifierLiteral
      return exec_identifier_literal(node, stack)
    end

    if node.is_a? CallExpression
      return exec_call_expression(node, stack)
    end

    if node.is_a? MemberExpression
      return exec_member_expression(node, stack)
    end

    if node.is_a? IndexExpression
      return exec_index_expression(node, stack)
    end

    if node.is_a? IfStatement
      return exec_if_statement(node, stack)
    end

    if node.is_a? WhileStatement
      return exec_while_statement(node, stack)
    end

    if node.is_a? NumericLiteral
      return exec_literal(node, stack)
    end

    if node.is_a? StringLiteral
      return exec_literal(node, stack)
    end

    if node.is_a? BooleanLiteral
      return exec_literal(node, stack)
    end

    if node.is_a? FunctionLiteral
      return exec_literal(node, stack)
    end

    if node.is_a? ArrayLiteral
      return exec_literal(node, stack)
    end

    if node.is_a? ClassLiteral
      return exec_literal(node, stack)
    end

    if node.is_a? ContainerLiteral
      return exec_container_literal(node, stack)
    end

    if node.is_a? NullLiteral
      return TNull.new
    end

    raise "Unknown node encountered #{node.class} #{stack}"
  end

  # Initializes a variable in the current stack
  # The value is set to TNull
  def exec_variable_declaration(node, stack)
    value = TNull.new
    identifier = node.identifier
    if identifier.is_a?(IdentifierLiteral)
      identifier_value = identifier.value
      if identifier_value.is_a?(String)
        stack.write(identifier_value, value, true)
      end
    end
    return value
  end

  # Saves value to a given variable in the current stack
  def exec_variable_initialisation(node, stack)

    # Resolve the value
    value = exec_expression(node.expression, stack)

    # Check for the identifier
    identifier = node.identifier
    if identifier.is_a? IdentifierLiteral
      identifier_value = identifier.value
      if identifier_value.is_a? String

        if value.is_a? BaseType
          stack.write(identifier_value, value, true)
        end
      end
    end
    return value
  end

  # Assign the result of an expression to a variable
  # in the current stack
  def exec_variable_assignment(node, stack)

    # Resolve the expression
    value = exec_expression(node.expression, stack)

    # Check if this is a member expression
    identifier = node.identifier
    if identifier.is_a? MemberExpression

      # Get some values
      member = identifier.member
      identifier = identifier.identifier

      # Resolve the identifier
      identifier = exec_expression(identifier.not_nil!, stack)

      # Only TObjects are allowed
      unless identifier.is_a?(TObject)
        raise "Can't write to non-object #{identifier}"
      end

      # Typecheck the member
      unless member.is_a?(IdentifierLiteral)
        raise "Member node is not an identifier. That's a bug"
      end

      # Check if the stack contains the value
      # TODO: Figure out object write behaviour if the key doesn't exist
      # Should we mimic javascript?
      if identifier.stack.contains(member.value.as(String))
        identifier.stack.write(member.value.as(String), value, false, false)
      else
        return TNull.new
      end
      return value
    elsif identifier.is_a? IndexExpression

      # Get some values
      member = identifier.member.not_nil!
      identifier = identifier.identifier.not_nil!

      # Resolve the identifier
      identifier = exec_expression(identifier, stack)

      # Only TArray and TString allowed
      if identifier.is_a?(TArray)

        # Resolve the member
        member = exec_expression(member, stack)

        # Typecheck the member
        if member.is_a?(TNumeric)

          # Out-of-bounds check
          if member.value < 0 || member.value > identifier.value.size - 1
            raise "Index out of bounds!"
          end

          # Write to the index
          identifier.value[member.value.to_i] = value
        else
          raise "Can't use #{member} in index expression."
        end
      else
        raise "Can't write to non-array #{identifier}"
      end
    else

      if identifier.is_a?(IdentifierLiteral)

        identifier_value = identifier.value
        if identifier_value.is_a?(String)

          # Check that the value is a BaseType
          if value.is_a? BaseType
            stack.write(identifier_value, value)
          end
        end
      end
    end

    value
  end

  # Extracts the value of a variable from the current stack
  def exec_identifier_literal(node, stack)
    stack.get(node.value)
  end

  def exec_unary_expression(node, stack)

    # Resolve the right side
    right = exec_expression(node.right, stack)

    case node.operator
    when MinusOperator
      if right.is_a? TNumeric
        return TNumeric.new(-right.value)
      end
    when NotOperator
      return TBoolean.new(!eval_bool(right, stack))
    end

    raise "Invalid operator or right-hand-side in unary expression"
  end

  def exec_binary_expression(node, stack)

    # Resolve the left and right side
    operator = node.operator
    left = exec_expression(node.left, stack)
    right = exec_expression(node.right, stack)

    if left.is_a?(TNumeric) && right.is_a?(TNumeric)
      case operator
      when PlusOperator
        return TNumeric.new(left.value + right.value)
      when MinusOperator
        return TNumeric.new(left.value - right.value)
      when MultOperator
        if left.value == 0 || right.value == 0
          return TNumeric.new(0)
        end
        return TNumeric.new(left.value * right.value)
      when DivdOperator
        if left.value == 0 || right.value == 0
          return TNull.new
        end
        return TNumeric.new(left.value / right.value)
      when ModOperator
        if right.value == 0
          return TNull.new
        end
        return TNumeric.new(left.value.to_i % right.value.to_i)
      when PowOperator
        return TNumeric.new(left.value ** right.value)
      end
    end

    if left.is_a?(TString) && right.is_a?(TString)
      case operator
      when PlusOperator
        return TString.new("#{left}" + "#{right}")
      end
    end

    if left.is_a?(TString) && !right.is_a?(TString)
      case operator
      when PlusOperator
        return TString.new("#{left}" + "#{right}")
      when MultOperator

        # Check if the right side is a TNumeric
        if right.is_a?(TNumeric)
          return TString.new(left.value * right.value.to_i)
        end
      end
    end

    if !left.is_a?(TString) && right.is_a?(TString)
      case operator
      when PlusOperator
        return TString.new("#{left}" + "#{right}")
      when MultOperator

        # Check if the left side is a TNumeric
        if left.is_a?(TNumeric)
          return TString.new(right.value * left.value.to_i)
        end
      end
    end

    raise "Invalid types or values inside binary expression"
  end

  # Perform a comparison
  def exec_comparison_expression(node, stack)

    # Resolve the left and right side
    left = exec_expression(node.left, stack)
    right = exec_expression(node.right, stack)
    operator = node.operator

    # When comparing TNumeric's
    if left.is_a?(TNumeric) && right.is_a?(TNumeric)

      # Different types of operators
      case operator
      when GreaterOperator
        return TBoolean.new(left.value > right.value)
      when LessOperator
        return TBoolean.new(left.value < right.value)
      when GreaterEqualOperator
        return TBoolean.new(left.value >= right.value)
      when LessEqualOperator
        return TBoolean.new(left.value <= right.value)
      when EqualOperator
        return TBoolean.new(left.value == right.value)
      when NotOperator
        return TBoolean.new(left.value != right.value)
      end
    end

    # When comparing TBools
    if left.is_a?(TBoolean) && right.is_a?(TBoolean)
      case operator
      when EqualOperator
        return TBoolean.new(left.value == right.value)
      when NotOperator
        return TBoolean.new(left.value != right.value)
      end
    end

    # When comparing strings
    if left.is_a?(TString) && right.is_a?(TString)
      case operator
      when GreaterOperator
        return TBoolean.new(left.value.size > right.value.size)
      when LessOperator
        return TBoolean.new(left.value.size < right.value.size)
      when GreaterEqualOperator
        return TBoolean.new(left.value.size >= right.value.size)
      when LessEqualOperator
        return TBoolean.new(left.value.size <= right.value.size)
      when EqualOperator
        return TBoolean.new(left.value == right.value)
      when NotOperator
        return TBoolean.new(left.value != right.value)
      end
    end

    # When comparing TFunc
    if left.is_a?(TFunc) && right.is_a?(TFunc)
      case operator
      when EqualOperator
        return TBoolean.new(left == right)
      when NotOperator
        return TBoolean.new(left != right)
      end
    end

    # When comparing TClass
    if left.is_a?(TClass) && right.is_a?(TClass)
      case operator
      when EqualOperator
        return TBoolean.new(left == right)
      when NotOperator
        return TBoolean.new(left != right)
      end
    end

    # When comparing TObject
    if left.is_a?(TObject) && right.is_a?(TObject)
      case operator
      when EqualOperator
        return TBoolean.new(left == right)
      when NotOperator
        return TBoolean.new(left != right)
      end
    end

    # If both sides are TNull
    if left.is_a?(TNull) && right.is_a?(TNull)
      case operator
      when EqualOperator
        return TBoolean.new(true)
      when NotOperator
        return TBoolean.new(false)
      end
    end

    # If the left side is bool
    if left.is_a?(TBoolean) && !right.is_a?(TBoolean)
      case operator
      when EqualOperator
        return TBoolean.new(left.value == eval_bool(right, stack))
      when NotOperator
        return TBoolean.new(left.value != eval_bool(right, stack))
      end
    end

    if !left.is_a?(TBoolean) && right.is_a?(TBoolean)
      case operator
      when EqualOperator
        return TBoolean.new(right.value == eval_bool(left, stack))
      when NotOperator
        return TBoolean.new(right.value != eval_bool(left, stack))
      end
    end

    return TBoolean.new(false)
  end

  # Execute an if statement
  def exec_if_statement(node, stack)

    # Resolve the test expression
    test = node.test
    if test.is_a?(ASTNode)
      test_result = eval_bool(exec_expression(node.test, stack), stack)
    else
      return TNull.new
    end

    # Run the respective handler
    if test_result
      consequent = node.consequent
      if consequent.is_a?(Block)
        return exec_block(consequent, Stack.new(stack))
      end
    else
      alternate = node.alternate
      if alternate.is_a?(ASTNode)
        if alternate.is_a?(IfStatement)
          return exec_if_statement(alternate, stack)
        elsif node.alternate.is_a?(Block)
          return exec_block(alternate, Stack.new(stack))
        end
      end
    end

    # Sanity check
    return TNull.new
  end

  # Executes a while node
  def exec_while_statement(node, stack)

    # Typecheck
    test = node.test
    consequent = node.consequent

    if test.is_a?(ASTNode) && consequent.is_a?(ASTNode)
      last_result = TNull.new
      while eval_bool(exec_expression(test, stack), stack)
        last_result = exec_block(consequent, Stack.new(stack))
      end
      return last_result
    else
      return TNull.new
    end
  end

  # Executes a call expression
  def exec_call_expression(node, stack)

    # Resolve all arguments
    arguments = [] of BaseType
    argumentlist = node.argumentlist
    if argumentlist.is_a? ExpressionList
      argumentlist.each do |argument|
        arguments << exec_expression(argument, stack)
      end
    end

    # Get the identifier of the call expression
    # If the identifier is an IdentifierLiteral we first check
    # if it's a call to "call_internal"
    # we are redirecting this
    identifier = node.identifier
    if identifier.is_a? IdentifierLiteral

      # Check for the "call_internal" name
      if identifier.value == "call_internal"

        name = arguments[0]
        if name.is_a? TString

          first_argument = arguments[1]?

          case name.value
          when "stdout_print"
            raise "Expected array" unless first_argument.is_a?(TArray)
            return InternalFunctions::STDOUT.print(first_argument.value, stack)
          when "stdout_write"
            raise "Expected array" unless first_argument.is_a?(TArray)
            return InternalFunctions::STDOUT.write(first_argument.value, stack)
          when "stderr_print"
            raise "Expected array" unless first_argument.is_a?(TArray)
            return InternalFunctions::STDERR.print(first_argument.value, stack)
          when "stderr_write"
            raise "Expected array" unless first_argument.is_a?(TArray)
            return InternalFunctions::STDERR.write(first_argument.value, stack)
          when "stdin_gets"
            return InternalFunctions::STDIN.gets
          when "stdin_getc"
            return InternalFunctions::STDIN.getc
          when "length"
            return InternalFunctions.length(arguments[1..-1], stack)
          when "array_of_size"
            return InternalFunctions.array_of_size(arguments[1..-1], stack)
          when "require"
            return exec_require(arguments[1..-1], stack)
          when "include"
            return exec_include(arguments[1..-1], stack)
          when "unpack"
            return InternalFunctions.unpack(arguments[1..-1], stack)
          when "time_ms"
            return TNumeric.new(Time.now.epoch_ms.to_f64)
          when "colorize"
            return InternalFunctions.colorize(arguments[1..-1], stack)
          when "exit"
            return InternalFunctions.exit(arguments[1..-1], stack)
          when "typeof"
            return InternalFunctions.typeof(arguments[1..-1], stack)
          else
            raise "Internal function call to '#{name.value}' not implemented!"
          end
        else
          raise "The first argument to call_internal has to be a string."
        end
      else
        target = stack.get(identifier.value)
      end
    else
      target = exec_expression(node.identifier, stack)
    end

    # Different handlers for different data types
    if target.is_a? TClass
      return exec_object_instantiation(target, arguments, stack)
    elsif target.is_a? TFunc
      return exec_function(target, arguments)
    else
      raise "#{identifier} is not a function!"
    end
  end

  # Executes a member expression
  def exec_member_expression(node, stack)
    identifier = exec_expression(node.identifier, stack)
    member = node.member

    # Typecheck
    if identifier.is_a?(TObject) && member.is_a?(IdentifierLiteral)

      # Check if the objects stack contains the given value
      if identifier.stack.contains(member.value)
        return identifier.stack.get(member.value, false)
      else
        return TNull.new
      end
    end

    raise "Could not perform member expression on #{identifier}!"
  end

  def exec_index_expression(node, stack)
    identifier = exec_expression(node.identifier, stack)
    member = node.member

    # Array index lookup
    if identifier.is_a?(TArray)

      # Resolve the identifier
      member = exec_expression(member, stack)

      # Typecheck
      if member.is_a?(TNumeric)

        # Check for out-of-bounds error
        if member.value > identifier.value.size - 1 || member.value < 0
          return TNull.new
        end

        # Return the value from the index
        return identifier.value[member.value.to_i]
      else
        raise "Invalid type #{member.class} for member expression"
      end
    end

    raise "Could not perform index expression on #{identifier}"
  end

  # Executes *function*, passing it *arguments*
  # inside *stack*
  # *function* is of type TFunc
  # *arguments* is an actual array of RunTimeType values
  def exec_function(function, arguments : Array(BaseType))

    # This needs to be here
    # altough we are 100% sure it will always be a TFunc here
    # crystal didn't stop complaining about it
    unless function.is_a? TFunc
      raise "Not a function!"
    end

    # Check if there is a parent stack
    parent_stack = function.block.parent_stack
    if parent_stack.is_a? Stack
      function_stack = Stack.new(parent_stack)
    else
      raise "Could not find a valid stack for the function to run in"
    end

    # Get the identities of the arguments that are required
    argument_ids = function.argumentlist.map { |argument|
      if argument.is_a? IdentifierLiteral && argument.value.is_a? String
        result = argument.value
      end
    }.compact

    # Write the __arguments variable into the stack
    __arguments = TArray.new(arguments)
    function_stack.write("__arguments", __arguments, true)

    # Write the argument to the function stack
    arguments.each_with_index do |arg, index|

      # Check for index out of bounds
      unless index < argument_ids.size
        next
      end

      # Write the argument into the stack
      id = argument_ids[index]
      if id.is_a? String
        function_stack.write(id, arg, true)
      end
    end

    # Check if the correct amount of arguments was passed
    if arguments.size < argument_ids.size
      raise "Function expected #{argument_ids.size} argument(s), got #{arguments.size}"
    end

    # Execute the block
    return exec_block(function.block, function_stack)
  end

  # Create an instance of a given class
  def exec_object_instantiation(classliteral, arguments, stack)

    # The stack for the object
    object_stack = Stack.new(classliteral.parent_stack)

    # Execute the class block inside the object_stack
    exec_block(classliteral.block, object_stack)

    # Search for the constructor of the class
    # and execute it in the object_stack if it was found
    if object_stack.contains("constructor")
      exec_function(object_stack.get("constructor"), arguments)

      # Remove the constructor again
      object_stack.delete("constructor")
    end

    # Create a new TObject and store the object_stack in it
    return TObject.new(object_stack)
  end

  def exec_literal(node, stack)
    case node
    when .is_a? NumericLiteral
      value = node.value
      if value.is_a?(String)
        return TNumeric.new(value.to_f)
      end
    when .is_a? StringLiteral
      value = node.value
      if value.is_a?(String)
        return TString.new(value)
      end
    when .is_a? BooleanLiteral
      value = node.value
      if value.is_a?(String)
        return TBoolean.new(value == "true")
      end
    when .is_a? FunctionLiteral
      argumentlist = node.argumentlist
      block = node.block

      if argumentlist.is_a? ASTNode && block.is_a? Block
        return TFunc.new(argumentlist.children, block, stack)
      end
    when .is_a? ArrayLiteral

      # Resolve all children first
      children = [] of BaseType
      node.children.map do |child|
        children << exec_expression(child, stack)
      end
      return TArray.new(children)
    when .is_a? ClassLiteral
      block = node.block

      if block.is_a? Block
        return TClass.new(block, stack)
      end
    when .is_a? NullLiteral
      return TNull.new
    end

    raise "Invalid literal found #{node.class}"
  end

  # Executes a container literal
  def exec_container_literal(node, stack)

    # Check if there is a block
    block = node.block
    if block.is_a? Block

      # Create the TClass instance
      classliteral = TClass.new(block, stack)

      # Create a new object from the class instance
      return exec_object_instantiation(classliteral, [] of BaseType, stack)
    end

    return TNull.new
  end

  # Require a file
  #
  # This is the exact same as writing include,
  # except that the returned object is cached
  # and the next requiring of this file will be served from that cache instead
  def exec_require(arguments, stack)

    # Check if a filename was passed
    # The filename will be resolved relative
    # to the directory of the current file
    filename = arguments[0]
    unless filename.is_a? TString
      raise "Calls to require expect the first argument to be a string. #{filename.class} given."
    end
    filepath = include_file_lookup(filename.value)

    # Check if this path is already cached
    if stack.top.session.try &.cached_require_calls.has_key?(filepath)

      # Type & sanity check
      cache = stack.top.session.try &.cached_require_calls[filepath]

      if cache.is_a?(BaseType)
        return cache
      else
        return TNull.new
      end
    else
      result = exec_include(arguments, stack, false)

      # Save the combination in the current session
      stack.top.session.try &.cached_require_calls[filepath] = result
      return result
    end
  end

  # Include a file
  #
  # Loads the contents of the file
  # The return value is the content of the *export* variable in the
  # included file
  def exec_include(arguments, stack, is_include = true)

    # Name of the function for error messages
    func = is_include ? "include" : "require"

    # Check if a filename was passed
    # The filename will be resolved relative
    # to the directory of the current file
    filename = arguments[0]
    unless filename.is_a? TString
      raise "Calls to #{func} expect the first argument to be a string. #{filename.class} given."
    end
    filepath = include_file_lookup(filename.value)

    # Check that the path is readable
    unless File.exists?(filepath) && File.readable?(filepath)
      raise "Could not open file at #{filepath}"
    end

    # Check if the path is a file
    if File.file?(filepath)

      # Create a new file from that path
      include_file = RealFile.new(filepath)

      # Create the stack for the interpreter
      include_stack = Stack.new(stack.top)
      include_stack.write("export", TNull.new, true)

      # Create a new InterpreterFascade
      # by passing it stack.top
      # it still has access to all the standard library functions
      # but doesn't have access to the current stack
      interpreter = InterpreterFascade.new(stack.top.session)
      result = interpreter.execute_file(include_file, include_stack)

      return include_stack.get("export")
    else
      raise "Could not open file at #{filepath}"
    end

    TNull.new
  end

  # Returns the absolute filepath to *filename*
  def include_file_lookup(filename)

    # Construct the relative path
    # by combining the current file and the file that's being included
    currentfile = @initial_stack.file
    unless currentfile.is_a? VirtualFile
      raise "Could not read current file from stack."
    end

    # Resolve the filename
    current_dir = currentfile.fulldirectorypath
    if filename[0] == '/'
      filepath = filename
    else

      # Check if a core module is being required
      case filename
      when "io"
        filepath = ENV["CHARLYDIR"] + "/io.charly"
      when "unit-test"
        filepath = ENV["CHARLYDIR"] + "/unit-test.charly"
      when "array"
        filepath = ENV["CHARLYDIR"] + "/array.charly"
      when "util"
        filepath = ENV["CHARLYDIR"] + "/util.charly"
      else
        filepath = File.join(current_dir, filename)
      end
    end
    filepath = File.expand_path(filepath) # Make it an absolute path
    filepath = File.real_path(filepath) # Resolve symlinks

    return filepath
  end

  # Returns the boolean representation of a value
  def eval_bool(value, stack)

    bool = false
    case value
    when .is_a? TNumeric
      bool = value.value != 0_f64
    when .is_a? TBoolean
      bool = value.value
    when .is_a? TString
      bool = true
    when .is_a? TFunc
      bool = true
    when .is_a? TObject
      bool = true
    when .is_a? TClass
      bool = true
    when .is_a? TArray
      bool = true
    when .is_a? TNull
      bool = false
    when .is_a? Bool
      bool = value
    end
    bool
  end
end
