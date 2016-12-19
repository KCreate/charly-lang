const Lib = require("./node.ch")
const NodeType = Lib.NodeType
const Node = Lib.Node
const Assertion = Lib.Assertion

class Context {
  property tree
  property current
  property depth
  property visitor

  func constructor(visitor) {
    @current = Node("Charly Unit Test Framework", NodeType.Root)
    @tree = @current
    @depth = 0
    @visitor = visitor
  }

  func add_node(type, title, callback) {
    @depth += 1

    const new = Node(title, type)
    const backup = @current
    @current.push(new, @depth)
    @current = new
    @visitor.on_node(@current, @depth, callback)
    @current = backup

    @depth -= 1
    self
  }

  func suite(title, callback) {
    @add_node(NodeType.Suite, title, callback)
  }

  func case(title, callback) {
    @add_node(NodeType.Test, title, callback)
  }

  func assert(real, expected) {
    const assertion = Assertion(real, expected)

    @current.push(
      assertion,
      @depth
    )

    @visitor.on_assertion(@current.length() - 1, assertion, @depth)
    self
  }
}

export = Context
