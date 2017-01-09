// Require
const require_no_prelude = __internal__method("require_no_prelude")
const require = __internal__method("require")
require.resolve = __internal__method("require_resolve")

/*
 * Primitive classes
 *
 * These modules export primitive classes.
 * If you were to replace the prelude with your own file,
 * make sure to include replacements for the following classes.
 * */
const Object =            require("./primitives/object.ch")
const Class =             require("./primitives/class.ch")
const PrimitiveClass =    require("./primitives/primitive-class.ch")
const Array =             require("./primitives/array.ch")
const String =            require("./primitives/string.ch")
const Numeric =           require("./primitives/numeric.ch")
const Function =          require("./primitives/function.ch")
const Boolean =           require("./primitives/boolean.ch")
const Null =              require("./primitives/null.ch")

// Anything IO related and some global bindings to commonly used methods
const io = require("./io.ch")
const print = io.stdout.print
const write = io.stdout.write
const gets = io.stdin.gets
const getc = io.stdin.getc
const exit = io.exit

const ExceptionClasses = require("./exceptions.ch")
const Exception = ExceptionClasses.Exception
const ArgumentError = ExceptionClasses.ArgumentError
const TypeError = ExceptionClasses.TypeError
