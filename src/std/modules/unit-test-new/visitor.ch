class TestVisitor {
  property write
  property print

  func constructor(write, print) {
    @write = write
    @print = print
  }

  func on_root(node) {
    @print((node.title).colorize(33))
  }

  func on_node(node, depth, callback) {
    callback()
  }

  func on_assertion(index, assertion, depth) {
    if assertion.passed() {
      @write(".".colorize(32))
    } else {
      @write("F".colorize(31))
    }
  }
}

export = TestVisitor
