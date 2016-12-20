class TestVisitor {
  property write
  property print

  func constructor(write, print) {
    @write = write
    @print = print
  }

  func on_root(node) {
    @print((node.title + " Graph").colorize(35))
  }

  func on_node(node, depth, callback) {
    @print(("- " + node.title.colorize(33)).indent(depth - 1, " "))
    callback()
  }

  func on_assertion(index, assertion, depth) {}
}

export = TestVisitor
