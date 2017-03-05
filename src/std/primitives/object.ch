const length = __internal__method("length")
const _colorize = __internal__method("colorize")
const _object_keys = __internal__method("_object_keys")
const _isolate_object = __internal__method("_isolate_object")
const _object_id = __internal__method("_object_id")

const PrettyPrintColors = {
  const String = 32
  const Numeric = 33
  const Boolean = 33
  const Null = 90
  const Function = 34
  const Class = 35
  const PrimitiveClass = 35
}

const PrettyPrintHistory = []

export = primitive class Object {

  /*
   * Returns a number that uniquely identifies *value*
   * */
  static func object_id(value) {
    _object_id(value)
  }

  /*
   * Returns the length of this value
   *
   * If self is a string, the amount of characters (not bytes) is returned
   * If self is an array, the amount of items inside is returned
   * If self is a numeric, itself is returned
   * Anything else will result in 0
   *
   * ```
   * "hello".length() // => 5
   * [1, 2, 3].length() // => 3
   * 5.length() // => 5
   * {}.length() // => 0
   * ```
   * */
  func length() {
    length(self)
  }

  /*
   * Non-recursively copies this object
   * */
  func copy() {
    Object.copy(self)
  }

  /*
   * Recusively copies this object
   * */
  func deep_copy() {
    Object.deep_copy(self)
  }

  func to_s() {
    if typeof self == "Object" {
      PrettyPrintHistory.push(Object.object_id(self))

      let render = "{\n"
      let child_render = ""

      Object.keys(self).each(->(key, index, size) {
        const own_key = self[key]

        if PrettyPrintHistory.includes(Object.object_id(own_key)) {
          child_render += key + ": " + "(circular)"
        } else {
          child_render += key + ": " + own_key.to_s()
        }

        if index < size - 1 {
          child_render += "\n"
        }
      })

      render += child_render.indent(2, " ")
      render += "\n}"

      PrettyPrintHistory.pop()

      return render
    } else {
      "" + self
    }
  }

  /*
   * Pretty prints *value*
   * */
  static func pretty_print(value) {
    const type = typeof value

    if type == "String" {
      return ("\"" + value + "\"").colorize(32)
    }

    if type == "Array" {
      return Array.pretty_print(value)
    }

    if type == "Object" {

      PrettyPrintHistory.push(Object.object_id(value))

      let render = "{\n"
      let child_render = ""

      Object.keys(value).each(->(key, index, size) {
        const own_key = value[key]

        if PrettyPrintHistory.includes(Object.object_id(own_key)) {
          child_render += key + ": " + "(circular)"
        } else {
          child_render += key + ": " + Object.pretty_print(own_key)
        }

        if index < size - 1 {
          child_render += "\n"
        }
      })

      render += child_render.indent(2, " ")
      render += "\n}"

      PrettyPrintHistory.pop()

      return render
    }

    return value.colorize(PrettyPrintColors[type])
  }

  /*
   * Calls to_s on self and colorizes it with the given *code*
   * This will wrap the string in bash color escape codes
   *
   * TODO: Find a way to generalize this?
   * */
  func colorize(code) {
    _colorize(@to_s(), code)
  }

  /*
   * Calls the callback with self and returns self
   *
   * ```
   * return 5.tap(->(value) { value + 5 }) // This will return 10
   * ```
   * */
  func tap(callback) {
    callback(self)
    self
  }

  /*
   * Calls each argument with self
   * Only functions are allowed as argument types
   * */
  func pipe() {
    const pipes = arguments

    pipes.each(func(pipe) {
      if typeof pipe ! "Function" {
        throw Exception("pipe expected an array of Functions, got: " + typeof pipe)
      }

      pipe(self)
    })

    self
  }

  /*
   * Same as pipe, but instead replaces self with the value returned by each callback
   * This is non-mutating
   * */
  func transform() {
    const pipes = arguments

    let result = self
    pipes.each(func(pipe) {
      if typeof pipe ! "Function" {
        throw Exception("transform expected an array of Functions, got: " + typeof pipe)
      }

      result = pipe(result)
    })

    result
  }

  /*
   * Returns all keys inside an object
   * */
  static func keys(object) {

    const allowed_types = [
      "Object",
      "Function",
      "Class",
      "PrimitiveClass"
    ]

    if allowed_types.index(typeof object, 0) == -1 {
      throw Exception("Expected object, function, class or primitive class, got " + typeof object)
    }

    _object_keys(object)
  }

  /*
   * Isolates this object from it's parent stack
   * This is mostly used in combination with eval to create an interpreter session
   * that doesn't have access to your current scope
   *
   * ```
   * let value = 25
   *
   * let box = {
   *   func foo() {
   *     return value
   *   }
   * }
   *
   * print(box.foo()) // => 25
   *
   * box.isolate()
   *
   * print(box.foo()) // => RunTimeError: value doesn't exist
   * ```
   * */
  static func isolate(object) {
    if typeof object ! "Object" {
      throw Exception("Expected object, got " + typeof object)
    }

    _isolate_object(object)
  }

  /*
   * Copies all keys from sources (assign(target, ...sources)) to the target
   * */
  static func assign(target) {
    const sources = arguments.range(1, arguments.length())
    sources.each(->(object) {
      const keys = Object.keys(object)
      keys.each(->(key) {
        target[key] = object[key]
      })
    })
    target
  }

  /*
   * Non-recursively copies a value
   *
   * Note: Functions, Classes, Primitive Classes cannot be copied
   * */
  static func copy(value) {
    const type = typeof value

    if type == "Function" {
      throw Exception("Cannot copy functions")
    }

    if type == "Class" {
      throw Exception("Cannot copy classes")
    }

    if type == "PrimitiveClass" {
      throw Exception("Cannot copy primitive classes")
    }

    if type == "Object" {
      return Object.assign({}, value)
    }

    if type == "Array" {
      return value.copy()
    }

    // Every value is considered to be a primitive at this point
    // We can safely return it back since they are passed by value anyway
    return value
  }

  /*
   * Recusively copies a value
   *
   * Note: Functions, Classes, Primitive Classes cannot be copied
   * */
  static func deep_copy(value) {
    const type = typeof value

    if type == "Function" {
      throw Exception("Cannot deep_copy functions")
    }

    if type == "Class" {
      throw Exception("Cannot deep_copy classes")
    }

    if type == "PrimitiveClass" {
      throw Exception("Cannot deep_copy primitive classes")
    }

    if type == "Object" {
      let new = {}
      Object.keys(value).each(->(key) {
        new[key] = value[key].deep_copy()
      })
      return new
    }

    if type == "Array" {
      return value.deep_copy()
    }

    // Every value is considered to be a primitive at this point
    // We can safely return it back since they are passed by value anyway
    return value
  }
}
