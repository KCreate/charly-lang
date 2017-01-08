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
      throw ArgumentError("Couldn't find the file " + filename, "Test")
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


TestRunner(filename)
