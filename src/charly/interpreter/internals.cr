require "./types.cr"

module Charly::Internals
  extend self

  # :nodoc:
  class Methods
    METHODS = [] of String
  end

  # Declare a new internal method called *name* with *types*
  #
  # ```
  # charly_api "sleep", time : TNumeric do
  #   sleep time.value
  #   return TString.new("Slept for #{time} seconds")
  # end
  # ```
  macro charly_api(name, *types, &block)
    class Methods
      def self.__charly_api_{{name.id}}(call, visitor, scope, context, argc : Int32, arguments : Array(BaseType))
        name = {{name}}
        types = [{{*types}}] of BaseType.class

        # Argument count check
        if argc < {{types.size}}
          raise RunTimeError.new(call.identifier, "#{{{name}}} expected #{types.size} arguments, got #{argc}")
        end

        # Argument type check
        {% for type, index in types %}

          arg{{index}} = arguments[{{index}}]

          if !arg{{index}}.is_a?({{type}})
            raise RunTimeError.new(call.argumentlist.children[{{index}}], "#{{{name}}} expected argument #{{{index + 1}}} to be of type #{{{type}}}, got #{arguments[{{index}}].class}")
          end

          {{block.args[index].id}} = arg{{index}}
        {% end %}

        {{block.body}}
      end

      METHODS << {{name}}
    end
  end
end

require "./internals/**"
