const stacktrace = __internal__method("stacktrace")

/*
 * Base class of all Exceptions
 *
 * @param String message The message of the exception
 * */
class Exception {
  property message
  property trace

  func constructor(message) {
    @message = message
    @trace = stacktrace()
    @trace = @trace.range(0, @trace.length() - 2)
  }

  func to_s() {
    let render = @__class.name + ": " + @message + "\n"
    @trace.each(->(entry) {
      render += entry.to_s().colorize(32) + "\n"
    })
    return render
  }
}

/*
 * Exceptions thrown when a specific argument is not
 * of the desired type or malformed, invalid in any
 * other form
 * */
class ArgumentError extends Exception {}

/*
 * Thrown on an invalid types
 * */
class TypeError extends Exception {}

export.Exception = Exception
export.ArgumentError = ArgumentError
export.TypeError = TypeError
