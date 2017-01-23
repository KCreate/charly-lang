const UnitTest = require("unit-test")
const result = UnitTest(->(describe, it, assert, context) {

  const testcases = [

    // Interpreter specs
    ["Arithmetic operations",       "./interpreter/arithmetic.ch"],
    ["Classes",                     "./interpreter/classes.ch"],
    ["Comments",                    "./interpreter/comments.ch"],
    ["Comparisons",                 "./interpreter/comparisons.ch"],
    ["Eval",                        "./interpreter/eval.ch"],
    ["Exceptions",                  "./interpreter/exceptions.ch"],
    ["Functions",                   "./interpreter/functions.ch"],
    ["Guard statement",             "./interpreter/guard.ch"],
    ["Including external files",    "./interpreter/external-files.ch"],
    ["Loops",                       "./interpreter/loops.ch"],
    ["Magic constants",             "./interpreter/magic-constants.ch"],
    ["Objects",                     "./interpreter/objects.ch"],
    ["Primitives",                  "./interpreter/primitives.ch"],
    ["Switch statements",           "./interpreter/switch.ch"],
    ["Ternary statements",          "./interpreter/ternary.ch"],
    ["Unless statement",            "./interpreter/unless.ch"],
    ["Variables",                   "./interpreter/variables.ch"],

    // Standard Library Specs
    ["Arrays",                      "./std/arrays.ch"],
    ["CLI",                         "./std/cli.ch"],
    ["Math",                        "./std/math.ch"],
    ["Numerics",                    "./std/numerics.ch"],
    ["Strings",                     "./std/strings.ch"]
  ]

  // Loads and runs all the test cases sequentially
  testcases.each(->(test) {
    const module = require(test[1])
    describe(test[0], ->{
      module(describe, it, assert, context)
    })
  })
})

UnitTest.display_result(result, ->(code) {
  exit(code)
})
