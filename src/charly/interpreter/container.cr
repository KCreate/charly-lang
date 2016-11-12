require "../exception.cr"
require "terminal_table"

module Charly
  class ContainerReferenceError < Exception
  end

  @[Flags]
  enum Flag
    INIT
    CONSTANT
    OVERWRITE_CONSTANT
    IGNORE_PARENT
    NONREADABLE
    FORCEREAD
  end

  # :nodoc:
  private class Entry(V)
    property value : V
    property flags : Flag

    def initialize(@value, @flags = Flag::None)
    end

    def is_constant
      @flags.includes? Flag::CONSTANT
    end

    def ===(other : V)
      @value == other
    end
  end

  # A `Container` is a Hash with a reference to another hash
  # This allows to store values in a hierarchy
  # Here it is used for CallStacks
  class Container(V)
    include Enumerable(Tuple(String, V, Flag))

    property parent : Container(V)?
    property values : Hash(String, Entry(V))

    def initialize(@parent)
      @values = {} of String => Entry(V)
    end

    # Initializes a new Container(V) with the parent set to nil
    def self.new
      return self.new(nil)
    end

    def each
      dump_values.each do |key, value, flags|
        yield ({key, value, flags})
      end
    end

    # :nodoc:
    def dump_values(parents : Bool = true)
      collection = [] of Tuple(String, V, Flag)

      # Add all parent values first
      if parents
        if (parent = @parent).is_a? Container(V)
          collection += parent.dump_values
        end
      end

      # Add the values of this stack
      @values.each do |key, value|
        collection << {key, value.value, value.flags}
      end

      return collection
    end

    # Writes to the container
    # Unless IGNORE_PARENT was passed as a flag,
    # this will try to write to all parent stacks if the key
    # is not found in this container
    #
    # Throws a ReferenceError in the following cases
    # - *key* is not defined
    # - *key* is a constant
    # - *key* Is already defined
    def write(key : String, value : V, flags : Flag = Flag::None) : V

      # Declarations
      if flags.includes? Flag::INIT

        # Check if the value already exists
        if contains key
          raise ContainerReferenceError.new("#{key} is already defined")
        end

        @values[key] = Entry(V).new(value, flags)
        return value
      end

      if contains key

        # Check if the value is a constant
        entry = @values[key]
        if !flags.includes?(Flag::OVERWRITE_CONSTANT) && entry.is_constant
          raise ContainerReferenceError.new("#{key} is a constant")
        end

        # Update the entry
        entry.value = value
        entry.flags = flags
        return value
      elsif !flags.includes?(Flag::IGNORE_PARENT) && (parent = @parent).is_a?(Container(V))
        return parent.write(key, value, flags)
      else
        raise ContainerReferenceError.new("#{key} is not defined")
      end
    end

    # Same as #write
    def []=(key : String, flags : Flag, value : V) : V
      write(key, value, flags)
    end

    # :ditto:
    def []=(key : String, value : V) : V
      write(key, value, Flag::None)
    end

    # Returns the entry for the *key*
    #
    # Throws a ReferenceError in the following cases
    # - *key* is not defined
    def get_reference(key : String, flags : Flag = Flag::None) : Entry(V)
      if contains key
        entry = @values[key]

        # Check if the value is readable
        if entry.flags.includes?(Flag::NONREADABLE) && !flags.includes?(Flag::FORCEREAD)
          raise ContainerReferenceError.new("#{key} is not defined")
        end

        return entry
      elsif !flags.includes?(Flag::IGNORE_PARENT) && (parent = @parent).is_a? Container(V)
        return parent.get_reference(key, flags)
      else
        raise ContainerReferenceError.new("#{key} is not defined")
      end
    end

    # Gets a value from the container or a parent one
    # Unless *IGNORE_PARENT* is passed as a flag
    # The parent containers will be searched
    #
    # Throws a ReferenceError in the following cases
    # - *key* is not defined
    def get(key : String, flags : Flag = Flag::None) : V
      get_reference(key, flags).value
    end

    # Same as #get
    def [](key : String, flags : Flag = Flag::None) : V
      get(key, flags)
    end

    # Deletes a value from the stack
    # Returns the value of the key
    #
    # Throws if the key was not found
    def delete(key : String, flags : Flag = Flag::None) : V
      if contains key
        old_value = @values[key].value
        @values.delete key
        return old_value
      elsif !flags.includes?(Flag::IGNORE_PARENT) && (parent = @parent).is_a? Container(V)
        return parent.delete(key, flags)
      else
        raise ContainerReferenceError.new("#{key} is not defined")
      end
    end

    # Returns the depth of this container
    #
    # Example
    #     Top - 0
    #     Middle - 1
    #     Bottom - 2
    def depth(n = 0)
      if (parent = @parent).is_a? Container(V)
        return parent.depth(n + 1)
      end
      n
    end

    # Checks if the current container contains *key*
    def contains(key : String, flags : Flag = Flag::None) : Bool
      @values.has_key? key

      if @values.has_key? key
        entry = @values[key]

        if entry.flags.includes?(Flag::NONREADABLE) && !flags.includes?(Flag::FORCEREAD)
          return false
        end

        return true
      end

      return false
    end

    # Checks if the current container _or_ any of the parent containers
    # contain *key*
    def defined(key : String) : Bool
      if contains key
        true
      elsif (parent = @parent).is_a? Container(V)
        parent.defined key
      else
        false
      end
    end

    # :nodoc:
    def finalize
      @values.clear
    end

    # :nodoc:
    def to_s(io)

      table = TerminalTable.new
      table.headings = ["Key", "Value", "Flags"]

      each do |key, value, flags|
        table << ["#{key}", "#{value}", "#{flags}"]
      end

      io << table.render
    end
  end
end
