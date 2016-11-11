require "./types.cr"

module Charly::Internals
  extend self

  METHODS = {} of String => InternalFuncType

  # Declare a new internal method called *name* with *types*
  #
  # ```
  # charly_api "sleep", time : TNumeric do
  #   sleep time.value
  #   return TString.new("Slept for #{time} seconds")
  # end
  # ```
  macro charly_api(name, *types, variadic = false)
    private def __{{name.id}}(call, context, argc : Int32, arguments : Array(BaseType))
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

        if !arg{{index}}.is_a?({{type.type}})
          raise RunTimeError.new(call.argumentlist[{{index}}], context, "#{{{name}}} expected argument #{{{index + 1}}} to be of type #{{{type.type}}}, got #{arguments[{{index}}].class}")
        end

        {{type.var}} = arg{{index}}
      {% end %}

      {{yield}}
    end

    METHODS[{{name}}] = ->__{{name.id}}(CallExpression, Context, Int32, Array(BaseType))
  end
end

require "./internals/**"
