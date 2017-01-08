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
class ArgumentError extends Exception {
  property propertyname

  func constructor(message, propertyname) {
    @message = message
    @propertyname = propertyname
  }

  func to_s() {
    "ArgumentError(" + @propertyname + "): " + @message
  }
}

/*
 * Thrown on an invalid types
 * */
class TypeError extends Exception {
  property expected
  property got
  property name

  func constructor(name, real, expected) {
    @name = name
    @real = real
    @expected = expected
  }

  func to_s() {
    "TypeError(" + @name + "): Expected variable to be of type \"" + @expected + "\", but got \"" + @real + "\""
  }
}

export.Exception = Exception
export.ArgumentError = ArgumentError
export.TypeError = TypeError
