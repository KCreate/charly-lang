class TestRunner {
  property filename
  property unit_test
  property result

  func constructor(filename) {
    @unit_test = require("unit-test")

    let module
    try {
      module = require(filename)
    } catch(e) {
      throw ArgumentError("Couldn't find the file " + filename)
    }

    // Make sure the exported value is a function
    guard typeof module == "Function" {
      throw ArgumentError("Couldn't find valid test inside " + filename + ". File exported a " + typeof module)
    }

    @result = @unit_test(->(describe, it, assert, context) {
      module(describe, it, assert, context)
    }).tap(->(result) {
      @unit_test.display_result(result, io.exit)
    })
  }
}

let filename = ARGV[0]

guard filename {
  print("Missing filename")
  io.exit(1)
}

unless filename[0] == "/" {
  filename = ENV.PWD + "/" + filename
}

try {
  TestRunner(filename)
} catch(e) {
  print(e.message)
}
