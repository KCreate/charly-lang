# Require
const require_no_prelude = __internal__method("require_no_prelude")
const require = __internal__method("require")
require.resolve = __internal__method("require_resolve")

func assert_type(type, value) {
  value.typeof() == type || value.instanceof() == type
}

# Primitives
const Object = require("./primitives/object.ch")
const Class = require("./primitives/class.ch")
const PrimitiveClass = require("./primitives/primitive-class.ch")
const Array = require("./primitives/array.ch")
const String = require("./primitives/string.ch")
const Numeric = require("./primitives/numeric.ch")
const Function = require("./primitives/function.ch")
const Boolean = require("./primitives/boolean.ch")
const Null = require("./primitives/null.ch")
const Reference = require("./primitives/reference.ch")

# IO related stuff
const io = require("./io.ch")
const print = io.stdout.print
const write = io.stdout.write
const gets = io.stdin.gets
const getc = io.stdin.getc
const exit = io.exit

class Exception {
  property message

  func constructor(message) {
    @message = message
  }

  func to_s() {
    "Uncaught " + @instanceof().name + ": " + @message
  }
}
