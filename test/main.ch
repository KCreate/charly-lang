const UnitTest = require("unit-test")
const result = UnitTest(->(describe, it, assert, context) {

  const testcases = [
    // ["Including external files",    "./external-files.ch"],
    // ["Variables",                   "./variables.ch"],
    // ["Arithmetic operations",       "./arithmetic.ch"],
    // ["Comparisons",                 "./comparisons.ch"],
    ["Arrays",                      "./std/arrays.ch"],
    // ["Numerics",                    "./numerics.ch"],
    ["Strings",                     "./std/strings.ch"]
    // ["Functions",                   "./functions.ch"],
    // ["Classes",                     "./classes.ch"],
    // ["Objects",                     "./objects.ch"],
    // ["Loops",                       "./loops.ch"],
    // ["CLI",                         "./cli.ch"],
    // ["Math",                        "./math.ch"],
    // ["try & catch",                 "./exceptions.ch"],
    // ["Magic constants",             "./magic-constants.ch"],
    // ["References",                  "./references.ch"],
    // ["Primitives",                  "./primitives.ch"],
    // ["Unless statement",            "./unless.ch"],
    // ["Guard statement",             "./guard.ch"],
    // ["Ternary statements",          "./ternary.ch"],
    // ["Comments",                    "./comments.ch"]
  ]

  // Loads and runs all the test cases sequentially
  testcases.each(->(test) {
    const module = require(test[1])
    describe(test[0], ->{
      module(describe, it, assert, context)
    })
  })
})

UnitTest.display_result(result, io.exit)
