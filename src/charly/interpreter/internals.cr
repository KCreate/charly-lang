require "./types.cr"

module Charly::Internals
  extend self

  METHODS = {} of String => InternalFuncType

  # :nodoc:
  macro charly_api(name, *types)
    private def {{name.id}}(call, context, argc : Int32, arguments : Array(BaseType))
      name = {{name}}
      types = [{{
        *types.map do |field|
          field.type
        end
      }}] of BaseType.class

      # Argument count check
      if argc < {{types.size}}
        raise RunTimeError.new(call.identifier, context, "#{{{name}}} expected #{types.size} arguments, got #{argc}")
      end

      # Argument type check
      {% for type, index in types %}

        arg{{index}} = arguments[{{index}}]

        unless arg{{index}}.is_a?({{type.type}})
          raise RunTimeError.new(call.identifier, context, "#{{{name}}} expected argument #{{{index}}} to be of type {{type.type}}, got #{arguments[{{index}}].class}")
        end
      {% end %}

      {{yield}}
    end

    METHODS[{{name}}] = ->{{name.id}}(CallExpression, Context, Int32, Array(BaseType))
  end

  charly_api "test", name : TString, age : TNumeric do
    puts "this is executed"
    return TString.new("lol")
  end
end
