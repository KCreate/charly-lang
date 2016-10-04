require "../syntax/ast/ast.cr"

module CharlyTypes

  # Internal representations of the types
  alias HashKey = String
  alias RunTimeType =
    String |
    Float64 |
    Bool |
    ASTNode |
    Nil

  # The base class all charly types depend on
  abstract class BaseType
    def initialize(value)
      @value = value
    end

    def to_s(io)
      string_value = MemoryIO.new
      value_to_s(string_value)
      io << "[#{self.class} : #{string_value.to_s}]"
    end

    abstract def value_to_s(io)
  end

  class TString < BaseType
    property value : String

    def value_to_s(io)
      io << value
    end
  end

  class TNumeric < BaseType
    property value : Float64

    def value_to_s(io)
      io << value
    end
  end

  class TBoolean < BaseType
    property value : Bool

    def value_to_s(io)
      if value
        io << "true"
      else
        io << "false"
      end
    end
  end

  class TNull < BaseType
    property value : Nil

    def initialize
      super(nil)
    end

    def value_to_s(io)
      io << "null"
    end
  end

  class TFunc < BaseType
    property argumentlist : Array(ASTNode)
    property block : Block
    property parent_stack : Stack

    def initialize(argumentlist, block, parent_stack)
      @value = false
      @argumentlist = argumentlist
      @block = block
      @block.parent_stack = parent_stack
      @parent_stack = parent_stack
    end

    def value_to_s(io)
      io << "Function"
    end
  end

  class TClass < BaseType
    property block : Block
    property parent_stack : Stack

    def initialize(block, parent_stack)
      @value = false
      @block = block
      @block.parent_stack = parent_stack
      @parent_stack = parent_stack
    end

    def value_to_s(io)
      io << "Class"
    end
  end

  class TObject < BaseType
    property stack : Stack

    def initialize(stack)
      @value = false
      @stack = stack
    end

    def value_to_s(io)
      io << "Object"
    end
  end
end
