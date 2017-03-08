require "../**"

module Charly::Internals
  charly_api "math", TString, TNumeric do |method, value|
    method = method.value
    value = value.value

    # Generate all math bindings
    {% for name in %w(cos cosh acos acosh sin sinh asin asinh tan tanh atan atanh cbrt sqrt log) %}
      if method == "{{name.id}}"
        return TNumeric.new(Math.{{name.id}}(value))
      end
    {% end %}

    if method == "ceil"
      return TNumeric.new(value.ceil)
    end

    if method == "floor"
      return TNumeric.new(value.floor)
    end

    if method == "rand"
      return TNumeric.new(rand)
    end

    raise RunTimeError.new(call.argumentlist.children[0], "Unknown math method")
  end
end
