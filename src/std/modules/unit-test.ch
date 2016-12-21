class Test {
  property title
  property catched_exception
  property assertions

  func constructor(title) {
    @title = title
    @catched_exception = null
    @assertions = []
  }

  func add(real, expect) {
    const match = real == expect
    @assertions.push([
      real, expect, match
    ])
  }

  func failed() {
    @assertions.map(func(assertion, i) {
      [
        i, assertion
      ]
    }).filter(func(assertion) {
      !assertion[1][2]
    })
  }

  func passed() {
    @failed().empty() && @catched_exception == null
  }
}

class Suite {
  property title
  property tests

  func constructor(title) {
    @title = title
    @tests = []
  }

  func add(test) {
    @tests.push(test)
  }

  func failed() {
    @tests.filter(func(test) {
      !test.passed()
    })
  }

  func passed() {
    @failed().empty()
  }
}

export = class UnitTest {
  property title
  property suites

  func constructor(title) {
    @title = title
    @suites = []
  }

  func failed() {
    @suites.filter(func(suite) {
      !suite.passed()
    })
  }

  func passed() {
    @failed().empty()
  }

  func begin(callback) {

    # Get the current time for statistics later on
    const start_time = io.time_ms()

    # Run all tests
    callback(func describe(description, callback) {
      const current_suite = Suite(description)

      print(("Suite: " + description).colorize(33))
      const start = io.time_ms()
      callback(func it(description, callback) {
        const current_test = Test(description)

        write(("it " + description + " ").colorize(37))
        const start = io.time_ms()

        try {
          callback(func assert(real, expect) {
            current_test.add(real, expect)
            null
          })
        } catch(e) {
          current_test.catched_exception = e
        }

        if (current_test.passed()) {
          write("Passed".colorize(32) + " " + (io.time_ms() - start) + "ms")
        } else {
          write("Failed".colorize(31) + " " + (io.time_ms() - start) + "ms")
        }
        print("")
        current_suite.add(current_test)
        null
      })
      print("Took: " + (io.time_ms() - start) + "ms")
      print("")

      # Add the current_suite to the suites array
      @suites.push(current_suite)

      null
    })

    # Gather some statistics
    let passed = true

    let suites_run = 0
    let tests_run = 0
    let assertions_run = 0
    let total_time = io.time_ms() - start_time

    # Extract the data
    @suites.each(func(suite, s_index) {

      suites_run += 1
      suite.tests.each(func(test, t_index) {

        if test.catched_exception == null {
          passed = false
        }

        tests_run += 1
        test.assertions.each(func(assertion, a_index) {

          assertions_run += 1
          if assertion[2] == false {
            passed = false
          }
        })
      })
    })

    # Show the statistics
    if (passed) {
      print("All test-suites have passed!".colorize(32))
    } else {
      print("Some test-suites have failed!".colorize(31))

      # Show all failed assertions in a nice graph
      @failed().each(func(suite) {

        print("- " + suite.title.colorize(33))
        suite.failed().each(func(test) {

          print("  - " + test.title.colorize(37))

          if test.catched_exception {
            print(("       Exception: " + test.catched_exception.message).colorize(31))
          } else {
            test.failed().each(func(assertion) {
              print("      " + (assertion[0] + 1) + ": " + ("Expected: >" + assertion[1][1] + "<, got: >" + assertion[1][0] + "<").colorize(31))
            })
          }
        })
      })

      print("")
    }
    print("Ran " + suites_run.colorize(33) + " Suites")
    print("Ran " + tests_run.colorize(33) + " Tests")
    print("Ran " + assertions_run.colorize(33) + " Assertions")
    print("Total time: " + total_time.colorize(33) + " miliseconds")

    # Return 0 if all tests passed
    # 1 if at least one failed
    if (passed) {
      0
    } else {
      1
    }
  }
}
