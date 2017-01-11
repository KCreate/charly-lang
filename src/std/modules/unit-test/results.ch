export = ->(results, callback) {

  // Print another newline to avoid conflicting with
  // the previous visitor
  print("\n")

  # Print if the session passed or not
  const status = results.passed()

  if status {
    print("All tests have passed".colorize(32))
  } else {
    print("Some test suites have failed".colorize(31))

    const failed_tests = {}

    let index = 1
    results.deep_failed(->(nodes) {

      // Extract the title of the failed test case
      const title = nodes.filter(->$1 > 0)
        .map(->$0.title)
        .join(" ")
      const fnode = nodes.last() // The actual assertion that failed

      write((index + ") ").colorize(31))
      print(title.colorize(31))

      write([
        ("Assertion #" + (fnode.index + 1)).colorize(34),
        "Expected: " + Object.pretty_print(fnode.expected),
        "Got: " + Object.pretty_print(fnode.real)
      ].join("\n").indent(" ", 2))

      print("")

      index += 1
    })
  }

  callback(status ? 0 : 1)
  return status
}
