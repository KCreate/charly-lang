class TestVisitor {
  property write
  property print

  func constructor(write, print) {
    @write = write
    @print = print
  }

  func on_node(title, depth, callback) {
    @print(("- " + title.colorize(33)).indent(depth - 1, " "))
    callback()
  }
}

export = TestVisitor
