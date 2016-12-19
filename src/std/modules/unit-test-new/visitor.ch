class TestVisitor {
  property write
  property print

  func constructor(write, print) {
    @write = write
    @print = print
  }

  func on_node(node, depth, callback) {
    @print(("- " + node.title.colorize(33)).indent(depth - 1, " "))
    callback()
  }

  func on_assertion(index, assertion, depth) {
    @write(("- " + (index + 1) + ". ").indent(depth, " "))
    @write(assertion.passed() ? "Passed".colorize(32) : "Failed".colorize(31))
    @write("\n")
  }
}

export = TestVisitor
