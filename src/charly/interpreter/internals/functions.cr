require "../**"

module Charly::Internals

  charly_api "function_bind", TFunc, BaseType, TArray do |function, context, bound_arguments|
    function = function.dup
    function.bound_arguments = function.bound_arguments.dup

    function.bound_context = context

    bound_arguments.value.each do |item|
      function.bound_arguments << item
    end

    return function
  end

  charly_api "is_internal", BaseType do |function|
    return TBoolean.new function.is_a?(TInternalFunc)
  end

end
