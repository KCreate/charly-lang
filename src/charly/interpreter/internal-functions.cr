require "./stack/stack.cr"
require "./types.cr"

# Defines all methods that are implemented in the interpreter directly
# This includes print, dump, rand, various math functions, etc.
module InternalFunctions
  extend self
  include CharlyTypes

  def sleep(arguments, stack)

    # Check if there is at least 1 argument
    unless arguments.size > 0
      return TNull.new
    end

    # An array filled with TNull
    if arguments.size >= 1

      # Typecheck
      amount = arguments[0]

      if amount.is_a?(TNumeric)
        sleep amount.value / 1000
      else
        raise "sleep expected argument 1 to be of type TNumeric, got #{amount.class}"
      end
    end

    return TNull.new
  end

  module STDOUT
    extend self

    def print(arguments, stack)
      arguments.each do |arg|
        ::STDOUT.puts arg
        ::STDOUT.flush
      end
      TNull.new
    end

    def write(arguments, stack)
      arguments.each do |arg|
        ::STDOUT.print arg
        ::STDOUT.flush
      end
      TNull.new
    end
  end

  module STDERR
    extend self

    def print(arguments, stack)
      arguments.each do |arg|
        ::STDERR.print arg
        ::STDERR.flush
      end
      TNull.new
    end

    def write(arguments, stack)
      arguments.each do |arg|
        ::STDERR.print arg
        ::STDERR.flush
      end
      TNull.new
    end
  end

  module STDIN
    extend self

    def getc
      char = ::STDIN.raw &.read_char
      return TString.new(char.to_s)
    end

    def gets
      return TString.new(::STDIN.gets || "")
    end
  end

  # Get the length of various types
  def length(arguments, stack)
    case arg = arguments[0]
    when .is_a? TNumeric
      return arg
    when .is_a? TString
      return TNumeric.new(arg.value.size.to_f64)
    when .is_a? TArray
      return TNumeric.new(arg.value.size.to_f64)
    else
      return TNull.new
    end
  end

  # Get an array of a given size
  # First argument has to be a numeric
  # An optional second argument can be used for the default value
  # All other arguments are ignored
  def array_of_size(arguments, stack)

    # Check if there are 2 arguments
    unless arguments.size > 0
      return TNull.new
    end

    # An array filled with TNull
    if arguments.size >= 2

      # Typecheck
      count = arguments[0]
      default = arguments[1]

      if count.is_a?(TNumeric)
        return TArray.new(Array.new(count.value.to_i64, default))
      else
        raise "array_of_size expected argument 1 to be of type TNumeric, got #{count.class}"
      end
    end

    return TNull.new
  end

  # Insert a value at a given index in an array
  def array_insert(arguments, stack)

    # We need at least 3 arguments
    if arguments.size >= 3
      array = arguments[0]
      index = arguments[1]
      value = arguments[2]

      # Typecheck
      if array.is_a?(TArray) && index.is_a?(TNumeric) && value.is_a?(BaseType)

        # If the index is smaller than 0, we shift to the beginning
        # If the index is bigger than the size of the array
        # we append to the end
        if index.value <= 0
          array.value.unshift(value)
        elsif index.value >= array.value.size
          array.value << value
        else
          array.value.insert(index.value.to_i64, value)
        end

        return array

      else
        raise "array_delete expected array, index, any"
      end

    end

    raise "array_insert expected at least 3 arguments"
  end

  # Delete a value at a given index in an array
  def array_delete(arguments, stack)

    # We need at least 2 arguments
    if arguments.size >= 2
      array = arguments[0]
      index = arguments[1]

      # Typecheck
      if array.is_a?(TArray) && index.is_a?(TNumeric)

        # If the index is smaller than 0, we delete the first element
        # If the index is bigger than the size of the array
        # we delete the last item
        if array.value.size == 0
          return TNull.new
        elsif index.value <= 0
          return array.value.shift
        elsif index.value >= array.value.size
          return array.value.pop
        else
          return array.value.delete_at(index.value.to_i64)
        end

        return array

      else
        raise "array_delete expected array, index"
      end

    end

    raise "array_delete expected at least 2 arguments"
  end

  # Dump all values from an object into it's parent stack
  def unpack(arguments, stack)

    # Check if there is at least 1 argument
    unless arguments.size > 0
      return TNull.new
    end

    object = arguments[0]
    if object.is_a?(TObject)

      # Get the correct stack
      # We assume this is called via the unpack method and not
      # call_internal("unpack", ...)
      #
      # This means we have to go up two stacks in order to
      # be able to write to the correct one
      #
      # the value variable we got from values is an entry in the stack
      # we need to unpack the value from the value
      object.stack.not_nil!.values.each do |key, value|
        stack.parent.not_nil!.write(key, value.value, true)
      end
    end
    return TNull.new
  end

  # Colorize a string with a given color code
  def colorize(arguments, stack)

    # Check if there are two arguments
    unless arguments.size > 0
      return TNull.new
    end

    if arguments.size >= 2
      text = arguments[0]
      color_code = arguments[1]

      # Typecheck
      unless color_code.is_a?(TNumeric)
        raise "colorize expected second argument to be of type TNumeric"
      end

      return TString.new("\e[#{color_code.value.to_i64}m#{text}\e[0m")
    end
    return TNull.new
  end

  # Exit the program
  # If the first argument is a TNumeric
  # It will be casted to an integer and used as the exit code
  def exit(arguments, stack)

    if arguments.size > 0
      code = arguments[0]

      if code.is_a? TNumeric
        exit code.value.to_i
      end
    end

    exit 0
  end

  # Returns the type of a literal as a string
  def typeof(arguments, stack)

    # Check if there is at least 1 argument
    if arguments.size > 0
      arg = arguments[0]
      return TString.new("#{arg.class}")
    end

    raise "typeof expected at least 1 argument"
  end

  # Converts a value to a numeric
  def to_numeric(arguments, stack)

    # Check if there is at least 1 argument
    if arguments.size > 0
      arg = arguments[0]

      if arg.is_a?(TString)
        num = arg.value.to_f64?(strict: false)

        if num.is_a? Float64
          return TNumeric.new(num)
        else
          return TNull.new
        end
      else
        raise "to_numeric expected a string, got #{arg.class}"
      end
    end

    raise "to_numeric expected at least 1 argument"
  end

  # Trim a string
  def trim(arguments, stack)

    # Check if there is at least 1 argument
    if arguments.size > 0
      arg = arguments[0]

      if arg.is_a?(TString)
        return TString.new(arg.value.strip)
      else
        raise "trim expected a string, got #{arg.class}"
      end
    end

    raise "trim expected at least 1 argument"
  end

  # Return the codepoint of a char as an array
  def ord(arguments, stack)

    # Check if there is at least 1 argument
    if arguments.size > 0
      arg = arguments[0]

      if arg.is_a?(TString) && arg.value.size > 0
        bytes = [] of BaseType
        arg.value[0].bytes.map do |byte|
          bytes << TNumeric.new(byte)
        end
        return TArray.new(bytes)
      else
        raise "trim expected a string with at least 1 char, got #{arg.class}"
      end
    end

    raise "ord expected at least 1 argument"
  end

  # Several math functions, the implementation of this might change
  def math(arguments, stack)

    # Check if there are at least 2 arguments
    if arguments.size >= 2
      func_name = arguments[0]
      unless func_name.is_a? TString
        raise "math expected first argument to be of type TString, got #{func_name.class}"
      end

      # The second argument has to be a numeric
      value = arguments[1]
      unless value.is_a? TNumeric
        raise "math expected second argument to be of type TNumeric, got #{func_name.class}"
      end

      # Generate all math bindings
      {% for name in %w(cos cosh acos acosh sin sinh asin asinh tan tanh atan atanh cbrt sqrt log) %}
      if func_name.value == "{{name.id}}"
        return TNumeric.new(Math.{{name.id}}(value.value))
      end
      {% end %}
      if func_name.value == "ceil"
        return TNumeric.new(value.value.ceil)
      end
      if func_name.value == "floor"
        return TNumeric.new(value.value.floor)
      end

      raise "Unknown math function #{func_name.value}"
    end

    raise "math expected at least 2 arguments"
  end
end
