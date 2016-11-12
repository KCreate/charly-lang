require "./container.cr"
require "../syntax/ast.cr"

module Charly

  # `BaseType` is the common class all types in charly depend on
  abstract class BaseType
    property data : Scope

    def initialize
      @data = Scope.new
    end

    # :nodoc:
    def to_s(io)
      value_to_s(io)
    end

    abstract def value_to_s(io)

    # :nodoc:
    private def display_data(data : Scope, io)
      values = data.dump_values(false)
      if values.size > 0
        io << ":("
        i = 0
        values.each do |key, value, flags|
          io << "#{key}"

          unless i == values.size - 1
            io << ", "
          end

          i += 1
        end
        io << ")"
      end
    end
  end

  # `TNumeric` is a 64 bit floating point number
  class TNumeric < BaseType
    property value : Float64

    def initialize(value)
      super()
      @value = value.to_f64
    end

    # :nodoc:
    def value_to_s(io)
      if @value.nan?
        io << "NAN"
        return
      end

      if value % 1 == 0
        io << value.to_i64
      else
        io << value
      end
    end

    # :nodoc:
    def self.to_s(io)
      io << "Numeric"
    end
  end

  class TString < BaseType
    property value : String

    def initialize(@value)
      super()
    end

    # :nodoc:
    def value_to_s(io)
      io << @value
    end

    # :nodoc:
    def self.to_s(io)
      io << "String"
    end
  end

  class TBoolean < BaseType
    property value : Bool

    def initialize(@value)
      super()
    end

    # :nodoc:
    def value_to_s(io)
      io << @value
    end

    # :nodoc:
    def self.to_s(io)
      io << "Boolean"
    end
  end

  class TArray < BaseType
    property value : Array(BaseType)

    def initialize(@value)
      super()
    end

    # :nodoc:
    def value_to_s(io)
      io << "Array:#{@value.size}"
    end

    # :nodoc:
    def self.to_s(io)
      io << "Array"
    end
  end

  class TFunc < BaseType
    property name : String?
    property argumentlist : IdentifierList
    property block : Block
    property parent_scope : Scope

    def initialize(@name, @argumentlist, @block, @parent_scope)
      super()
    end

    # :nodoc:
    def value_to_s(io)
      io << "Function:#{@argumentlist.children.size}"
    end

    # :nodoc:
    def self.to_s(io)
      io << "Function"
    end
  end

  # This is a quick and dirty workaround
  # This is currently a limitation of the language
  # See: https://github.com/crystal-lang/crystal/issues/3532
  alias InternalFuncType =  Proc(CallExpression, Scope, Context, Int32, Array(BaseType), TArray) |
                            Proc(CallExpression, Scope, Context, Int32, Array(BaseType), TBoolean) |
                            Proc(CallExpression, Scope, Context, Int32, Array(BaseType), TClass) |
                            Proc(CallExpression, Scope, Context, Int32, Array(BaseType), TFunc) |
                            Proc(CallExpression, Scope, Context, Int32, Array(BaseType), TInternalFunc) |
                            Proc(CallExpression, Scope, Context, Int32, Array(BaseType), TNull) |
                            Proc(CallExpression, Scope, Context, Int32, Array(BaseType), TNumeric) |
                            Proc(CallExpression, Scope, Context, Int32, Array(BaseType), TObject) |
                            Proc(CallExpression, Scope, Context, Int32, Array(BaseType), TPrimitiveClass) |
                            Proc(CallExpression, Scope, Context, Int32, Array(BaseType), TString)
                            Proc(CallExpression, Scope, Context, Int32, Array(BaseType), BaseType)

  class TInternalFunc < BaseType
    property name : String
    property method : InternalFuncType

    def initialize(@name, @method)
      super()
    end

    # :nodoc:
    def value_to_s(io)
      io << "Function"
    end

    # :nodoc:
    def self.to_s(io)
      io << "Function"
    end
  end

  class TClass < BaseType
    property name : String
    property properties : Array(IdentifierLiteral)
    property methods : Array(FunctionLiteral)
    property parents : Array(TClass)
    property parent_scope : Scope

    def initialize(@name, @properties, @methods, @parents, @parent_scope)
      super()
    end

    # :nodoc:
    def value_to_s(io)
      io << "Class:#{@parents.size}:#{@name}"
    end

    # :nodoc:
    def self.to_s(io)
      io << "Class"
    end
  end

  class TPrimitiveClass < BaseType
    property name : String
    property parent_scope : Scope

    def initialize(@name, @parent_scope)
      super()
    end

    # :nodoc:
    def value_to_s(io)
      io << "PrimitiveClass:#{@name}"
      display_data(@data, io)
    end

    # :nodoc:
    def self.to_s(io)
      io << "PrimitiveClass"
    end
  end

  class TObject < BaseType
    property type : TClass

    def initialize(@type)
      super()
    end

    # :nodoc:
    def value_to_s(io)
      io << "Object:#{@type.name}"
      display_data(@data, io)
    end

    # :nodoc:
    def self.to_s(io)
      io << "Object"
    end
  end

  class TNull < BaseType
    def initialize
      super()
    end

    # :nodoc:
    def value_to_s(io)
      io << "null"
    end

    # :nodoc:
    def self.to_s(io)
      io << "Null"
    end
  end
end
