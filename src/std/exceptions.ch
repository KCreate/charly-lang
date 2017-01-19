/*
 * Base class of all Exceptions
 *
 * @param String message The message of the exception
 * */
class Exception {
  property message

  func constructor(message) {
    @message = message
  }

  func to_s() {
    "Exception: " + @message
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
