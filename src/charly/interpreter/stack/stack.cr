require "../types.cr"
require "../../file.cr"
require "../session.cr"
require "./entry.cr"

# A single stack containing variables
class Stack
  include CharlyTypes
  property parent : Stack?
  property file : VirtualFile?
  property values : Hash(HashKey, StackEntry)
  property locked : Bool
  property session : Session?

  def initialize(parent)
    @parent = parent
    @values = {} of HashKey => StackEntry
    @locked = false
  end

  def to_s(io)
    stackdump(io)
  end

  def dump_values
    collection = [] of Tuple(Int64, HashKey, StackEntry)

    # Add all parent values first
    parent = @parent
    if parent.is_a? Stack
      collection += parent.dump_values
    end

    # Add the values of this stack
    @values.each do |key, value|
      collection << {depth, key, value}
    end

    return collection
  end

  def stackdump(io, head = false)

    # Header
    io << "## Stackdump\n" if head

    # Display all values as a table
    max_depth = 0
    max_id = 0
    max_val = 0
    max_type = 0
    dump_values.each do |(depth, key, value)|
      depth = "#{depth}"[0..30]
      key = "#{key}"[0..30]
      value = "#{value.value} #{value.locked ? "locked" : ""}"[0..30]
      type = "#{value.class}"[0..30]

      max_depth = depth.size if depth.size > max_depth
      max_id = key.size if key.size > max_id
      max_val = value.size if value.size > max_val
      max_type = type.size if type.size > max_type
    end

    dump_values.each do |(depth, key, value)|
      io << "#{depth}".ljust(max_depth, ' ')
      io << " "
      io << "#{key}".ljust(max_id, ' ')
      io << " : "
      io << "#{value.value} #{value.locked ? "locked" : ""}".ljust(max_val, ' ')
      io << " : "
      io << "#{value.value.class}".ljust(max_type, ' ')
      io << "\n"
    end
  end

  def clear
    @values.clear
  end

  def depth(n = 0_i64)
    parent = @parent
    if parent.is_a? Stack
      return parent.depth(n + 1_i64)
    end
    return n
  end

  def top
    parent = @parent
    if parent.is_a? Stack
      return parent.top
    end
    return self
  end

  def lock
    @locked = true
  end

  def unlock
    @locked = false
  end

  def write(key, value : BaseType, declaration = false, check_parent = true, constant = false)

    # Check if this is a declaration
    if declaration

      # Check if the stack is locked
      if @locked
        raise "Can't mutate '#{key}', stack is locked!"
      else

        # Check if the value already exists
        if contains(key) && (entry = @values[key]).locked
          raise "Can't reinitialize constant '#{key}'"
        end

        value = StackEntry.new(value)
        value.locked = constant
        @values[key] = value
        return value
      end
    end

    # Check if the current stack contains the key
    parent = @parent
    if contains key
      if (entry = @values[key]).locked
        raise "Can't change '#{key}', variable is a constant"
      else
        @values[key] = StackEntry.new(value)
      end
      return value
    elsif check_parent && parent.is_a?(Stack)
      return parent.write(key, value, false, true)
    else
      raise "'#{key}' is not declared"
    end
  end

  # Deletes a key from the stack
  # Also checks the parents
  def delete(key, check_parent = true)

    # Check if the current stack contains the key
    parent = @parent
    if contains key
      old_value = @values[key].value
      @values.delete key
      return old_value
    elsif check_parent && parent.is_a? Stack
      return parent.delete(key, check_parent)
    else
      raise "Could not delete '#{key}', not found!"
    end
  end

  # Get a key from the stack
  # If the key doesn't exist, check the parent stack
  # unless *check_parent* is passed
  def get(key, check_parent = true) : BaseType
    parent = @parent
    if contains key
      return @values[key].value
    elsif check_parent && parent.is_a? Stack
      return parent.get(key)
    else
      raise "'#{key}' is not defined"
    end
  end

  # Check if the current stack contains a value
  def contains(key)
    return @values.has_key? key
  end

  # Check if the current stack, or any of it's parents stack
  # contain a given key
  def defined(key)
    parent = @parent
    if contains(key)
      return true
    elsif parent.is_a? Stack
      return parent.defined(key)
    else
      return false
    end
  end
end
