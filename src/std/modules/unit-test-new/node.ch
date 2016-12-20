const NodeType = {
  const Root = 0
  const Suite = 1
  const Test = 2
  const Assertion = 3
}

class Node {
  property title
  property children
  property type

  func constructor(title, type) {
    @title = title
    @type = type
    @children = []
  }

  func push(node, depth) {
    @children.push(node)
    self
  }

  func passed() {
    let passed = true
    @children.each(->(child) {
      if passed {
        passed = child.passed()
      }
    })
    passed
  }

  func length() {
    @children.length()
  }
}

class Assertion extends Node {
  property expected
  property real
  property has_passed

  func constructor(expected, real) {
    @id = get_node_id()
    @title = ""
    @children = []
    @type = NodeType.Assertion
    @expected = expected
    @real = real
    @has_passed = expected == real
  }

  func passed() {
    @has_passed
  }
}

export.Node = Node
export.NodeType = NodeType
export.Assertion = Assertion
