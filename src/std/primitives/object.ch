const length = __internal__method("length")
const _colorize = __internal__method("colorize")
const typeof = __internal__method("typeof")
const instanceof = __internal__method("instanceof")
const _object_keys = __internal__method("_object_keys")
const _isolate_object = __internal__method("_isolate_object")

export = primitive class Object {

  /*
   * Returns a reference to self
   *
   * If self is already a reference, this will dereference it
   * */
  func reference() {
    &self
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

  func pretty_print() {
    if @typeof() == "Object" {
      let render = "{\n"

      let child_render = ""
      Object.keys(self).each(->(key, index, size) {
        const own_key = self[key]

        if own_key == self && own_key.typeof() == @typeof() {
          child_render += key + ": (circular)"
        } else {
          child_render += key + ": " + self[key].pretty_print()
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
    if object.typeof() ! "Object" {
      throw Exception("Expected object, got " + object.typeof())
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
}
