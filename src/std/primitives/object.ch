const length = __internal__method("length")
const _colorize = __internal__method("colorize")
const typeof = __internal__method("typeof")
const instanceof = __internal__method("instanceof")
const _object_keys = __internal__method("_object_keys")
const _isolate_object = __internal__method("_isolate_object")

const PrettyPrintColors = {
  const String = 32
  const Numeric = 33
  const Boolean = 33
  const Null = 90
  const Function = 34
  const Class = 35
  const PrimitiveClass = 35
}

export = primitive class Object {

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
    if @typeof() == "Object" {
      let render = "{\n"

      let child_render = ""
      Object.keys(self).each(->(key, index, size) {
        const own_key = self[key]

        if own_key == self && own_key.typeof() == @typeof() {
          child_render += key + ": " + "(circular)"
        } else {
          child_render += key + ": " + self[key].to_s()
        }

        if index < size - 1 {
          child_render += "\n"
        }
      })

      render += child_render.indent(2, " ")
      render += "\n}"

      return render
    } else {
      "" + self
    }
  }

  /*
   * Pretty prints *value*
   * */
  static func pretty_print(value) {
    const type = value.typeof()

    if type == "String" {
      return ("\"" + value + "\"").colorize(32)
    }

    if type == "Array" {
      return Array.pretty_print(value)
    }

    if type == "Object" {

      let render = "{\n"
      let child_render = ""

      Object.keys(value).each(->(key, index, size) {
        const own_key = value[key]

        if own_key == value && own_key.typeof() == value.typeof() {
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
   * Returns the type of a variable as a string
   *
   * ```
   * 5.typeof() // => "Numeric"
   * "hello world".typeof() // => "String"
   * {}.typeof() // => "Object"
   * MyClass().typeof() // => "Object"
   * ```
   * */
  func typeof() {
    typeof(self)
  }

  /*
   * If self is an object, this returns the class it was constructed from
   * If self wasn't created from a class (via a container literal for example), null is returned
   * */
  func instanceof() {
    instanceof(self)
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
      if pipe.typeof() ! "Function" {
        throw Exception("pipe expected an array of Functions, got: " + pipe.typeof())
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
      if pipe.typeof() ! "Function" {
        throw Exception("transform expected an array of Functions, got: " + pipe.typeof())
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

    if allowed_types.index_of(object.typeof()) == -1 {
      throw Exception("Expected object, function, class or primitive class, got " + object.typeof())
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
    if object.typeof() ! "Object" {
      throw Exception("Expected object, got " + object.typeof())
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
    const type = value.typeof()

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
    const type = value.typeof()

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
