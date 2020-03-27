const is_internal = __internal__method("is_internal")
const function_bind = __internal__method("function_bind")
const function_run = __internal__method("function_run")
const function_run_with_context = __internal__method("function_run_with_context")

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

  /*
   * Runs the function in the standard context with the arguments inside
   * *arguments*
   **/
  func run(arguments) {
    if typeof arguments ! "Array" {
      throw Exception("Expected argument to be an array")
    }

    return function_run(self, arguments)
  }

  func run_with_context(context, arguments) {
    if typeof arguments ! "Array" {
      throw Exception("Expected argument to be an array")
    }

    return function_run_with_context(self, context, arguments)
  }
}
