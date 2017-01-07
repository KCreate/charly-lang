const UnitTest = require("unit-test")
const result = UnitTest(->(describe, it, assert, context) {

  const testcases = [

    // Interpreter specs
    ["Variables",                   "./interpreter/variables.ch"],
    ["Arithmetic operations",       "./interpreter/arithmetic.ch"],
    ["Comparisons",                 "./interpreter/comparisons.ch"],
    ["Functions",                   "./interpreter/functions.ch"],
    ["Classes",                     "./interpreter/classes.ch"],
    ["Including external files",    "./interpreter/external-files.ch"],
    // ["Objects",                     "./objects.ch"],
    ["Loops",                       "./interpreter/loops.ch"],
    ["Exceptions",                  "./interpreter/exceptions.ch"],
    ["Magic constants",             "./interpreter/magic-constants.ch"],
    ["Primitives",                  "./interpreter/primitives.ch"],
    ["Unless statement",            "./interpreter/unless.ch"],
    ["Guard statement",             "./interpreter/guard.ch"],
    ["Ternary statements",          "./interpreter/ternary.ch"],
    ["Comments",                    "./interpreter/comments.ch"],

    // This is commented out because of #142
    // ["References",                  "./interpreter/references.ch"],

    // Standard Library Specs
    ["Arrays",                      "./std/arrays.ch"],
    ["Numerics",                    "./std/numerics.ch"],
    ["Strings",                     "./std/strings.ch"],
    ["CLI",                         "./std/cli.ch"],
    ["Math",                        "./std/math.ch"]
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
