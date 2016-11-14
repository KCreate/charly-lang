require "./container.cr"
require "../syntax/ast.cr"

module Charly

  # The basetype of all types in charly
  abstract class BaseType
    abstract def name(io) : String

    def to_s(io)
      name(io)
    end

    def self.to_s(io)
      self.name(io)
    end

    def self.name(io)
      io << "BaseType"
    end
  end

  # The basetype of all types in charly that have their own data scope
  # Objects, Classes, Functions, etc.
  abstract class DataType < BaseType
    property data : Scope

    def initialize
      super()
      @data = Scope.new
    end
  end

  # The basetype of all types in charly that don't have their own data scope
  # Numeric, String, Boolean, Array
  abstract class PrimitiveType(T) < BaseType
    property value : T

    def initialize(@value : T)
      super()
    end
  end

  # Numeric
  class TNumeric < PrimitiveType(Float64)

    def self.new(value : Number)
      self.new(value.to_f64)
    end

    def name(io)
      if @value.nan?
        io << "NAN"
      else
        io << @value
      end
    end

    def self.name(io)
      io << "Numeric"
    end
  end

  # Strings
  class TString < PrimitiveType(String)
    def name(io)
      io << @value
    end

    def self.name(io)
      io << "String"
    end
  end

  # Booleans
  class TBoolean < PrimitiveType(Bool)
    def name(io)
      io << @value ? "true" : "false"
    end

    def self.name(io)
      io << "Boolean"
    end
  end

  # An array of BaseTypes
  class TArray < PrimitiveType(Array(BaseType))
    def name(io)
      io << "Array:#{@value.size}"
    end

    def self.name(io)
      io << "Array"
    end
  end

  # The null type
  class TNull < BaseType
    def name(io)
      io << "null"
    end

    def self.name(io)
      io << "Null"
    end
  end

  # An object
  class TObject < DataType
    property type : TClass?

    def initialize(@type = nil)
      super()
    end

    def name(io)
      if (type = @type).is_a? TClass
        io << "Object:#{type.name}"
      else
        io << "Object:Container"
      end
    end

    def self.name(io)
      io << "Array"
    end
  end

  # A class
  class TClass < DataType
    property name : String
    property properties : Array(IdentifierLiteral)
    property methods : Array(FunctionLiteral)
    property parents : Array(TClass)
    property parent_scope : Scope

    def initialize(@name, @properties, @methods, @parents, @parent_scope)
      super()
    end

    def name(io)
      io << "Class:#{@parents.size}"
    end

    def self.name(io)
      io << "Class"
    end
  end

  # A primitive type
  class TPrimitiveClass < DataType
    property name : String
    property parent_scope : Scope

    def initialize(@name, @parent_scope)
      super()
    end

    def name(io)
      io << "PrimitiveClass:#{@name}"
    end

    def self.name(io)
      io << "PrimitiveClass"
    end
  end

  # A regular function
  class TFunc < DataType
    property name : String?
    property argumentlist : IdentifierList
    property block : Block
    property parent_scope : Scope

    def initialize(@name, @argumentlist, @block, @parent_scope)
      super()
    end

    def name(io)
      io << "Function:#{@argumentlist.size}"
    end

    def self.name(io)
      io << "Function"
    end
  end

  # This is a quick and dirty workaround
  # This is currently a limitation of the language
  # See: https://github.com/crystal-lang/crystal/issues/3532
  alias InternalFuncType =  Proc(CallExpression, Interpreter, Scope, Context, Int32, Array(BaseType), BaseType)

  # A bound internal method
  class TInternalFunc < DataType
    property name : String
    property method : InternalFuncType

    def initialize(@name, @method)
      super()
    end

    def name(io)
      io << "Function"
    end

    def self.name(io)
      io << "Function"
    end
  end

end
