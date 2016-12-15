const length = __internal__method("length")
const _colorize = __internal__method("colorize")
const typeof = __internal__method("typeof")
const instanceof = __internal__method("instanceof")
const _object_keys = __internal__method("_object_keys")
const _isolate_object = __internal__method("_isolate_object")

export = primitive class Object {

  # Returns a reference to self
  #
  # If self is already a reference, this will dereference it
  func reference() {
    &self
  }

  func length() {
    length(self)
  }

  func to_s() {
    if @typeof() == "Object" {
      let render = "{\n"

      let child_render = ""
      Object.keys(self).each(->(key, index, size) {

        if self[key] == self {
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
        if self[key] == self {
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

  func colorize(code) {
    _colorize(self.to_s(), code)
  }

  func typeof() {
    typeof(self)
  }

  func instanceof() {
    instanceof(self)
  }

  # Pipes self into *other*
  # Other has to be a function
  func call(other) {
    if (other.typeof() == "Function") {
      other(self)
    }
  }

  # Passes self to the callback
  # Returns self
  func tap(callback) {
    callback(self)
    self
  }

  func pipe() {
    const pipes = arguments

    if pipes.typeof() ! "Array" {
      raise Exception("pipe expected argument to be of type Array, got: " + pipes.typeof())
    }

    pipes.each(func(pipe) {
      if pipe.typeof() ! "Function" {
        raise Exception("pipe expected an array of Functions, got: " + pipe.typeof())
      }

      pipe(self)
    })

    self
  }

  func transform() {
    const pipes = arguments

    if pipes.typeof() ! "Array" {
      raise Exception("transform expected argument to be of type Array, got: " + pipes.typeof())
    }

    let result = self
    pipes.each(func(pipe) {
      if pipe.typeof() ! "Function" {
        raise Exception("transform expected an array of Functions, got: " + pipe.typeof())
      }

      result = pipe(result)
    })

    result
  }

  static func keys(object) {
    if object.typeof() ! "Object" {
      throw Exception("Expected object, got " + object.typeof())
    }

    _object_keys(object)
  }

  static func isolate(object) {
    if object.typeof() ! "Object" {
      throw Exception("Expected object, got " + object.typeof())
    }

    _isolate_object(object)
  }
}
