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

export.Exception = Exception
