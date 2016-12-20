export = ->(results, callback) {

  # Print if the session passed or not
  const status = results.passed()

  if status {
    print("All tests have passed".colorize(32))
  } else {
    print("Some test suites have failed".colorize(31))

    results.deep_failed(->(nodes) {
      nodes.each(->(node, depth) {
        print(node.title.indent(depth, " ") + " - " + node.id.colorize(32))
      })
    })
  }

  callback(status ? 1 : 0)
  return status
}
