require "./session.cr"
require "./types.cr"

# A single stack containing variables
class Stack
  include CharlyTypes
  property parent : Stack?
  property session : Session
  property values : Hash(HashKey, BaseType)
  property locked : Bool

  def initialize(parent, session)
    @parent = parent
    @session = session
    @values = {} of HashKey => BaseType
    @locked = false
  end

  def to_s(io)
    stackdump(io)
  end

  def stackdump(io, head = false)

    # Header
    io << "## Stackdump\n" if head

    # Print all parent stacks first
    parent = @parent
    if parent.is_a? Stack
      parent.stackdump(io, true)
    end

    # Display all values as a table
    @values.each do |key, value|
      io << depth
      io << " "
      io << self.object_id
      io << " "
      io << "#{key}"
      io << " : "
      io << "#{value}"
      io << "\n"
    end
  end

  def clear
    @values.clear
  end

  def depth(n = 0)
    parent = @parent
    if parent.is_a? Stack
      return parent.depth(n + 1)
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

  def session
    parent = @parent
    if parent.is_a? Stack
      return parent.session
    end
    return @session
  end

  def lock
    @locked = true
  end

  def unlock
    @locked = false
  end

  def write(key, value, declaration = false, check_parent = true)

    # Check if this is a declaration
    if declaration

      # Check if the stack is locked
      if @locked
        raise "Could not write to variable '#{key}', stack is locked!"
      else
        @values[key] = value
        return value
      end
    end

    # Check if the current stack contains the key
    parent = @parent
    if contains key
      @values[key] = value
      return value
    elsif check_parent && parent.is_a?(Stack)
      return parent.write(key, value, false, true)
    else
      raise "Could not write to variable '#{key}', variable wasn't declared!"
    end
  end

  # Deletes a key from the stack
  # Also checks the parents
  def delete(key, check_parent = true)

    # Check if the current stack contains the key
    parent = @parent
    if contains key
      old_value = @values[key]
      @values.delete key
      return old_value
    elsif check_parent && parent.is_a? Stack
      return parent.delete(key, check_parent)
    else
      raise "Could not delete variable '#{key}', not found!"
    end
  end

  # Get a key from the stack
  # If the key doesn't exist, check the parent stack
  # unless *check_parent* is passed
  def get(key, check_parent = true)
    parent = @parent
    if contains key
      return @values[key]
    elsif check_parent && parent.is_a? Stack
      return parent.get(key)
    else
      raise "Variable '#{key}' is not defined!"
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