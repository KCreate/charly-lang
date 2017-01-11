const is_internal = __internal__method("is_internal")
const function_bind = __internal__method("function_bind")

export = primitive class Function {

  /*
   * Binds given context and arguments to a function
   * This returns a copy of the function
   * */
  func bind(context) {
    if is_internal(self) {
      throw Exception("Cannot bind context and arguments to internal functions")
    }

    const bound_arguments = arguments.range(1, arguments.length())
    return function_bind(self, context, bound_arguments)
  }
}
