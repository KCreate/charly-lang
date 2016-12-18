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
}

class Assertion extends Node {
  property expected
  property real
  property has_passed

  func constructor(expected, real) {
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

class Context {
  property tree
  property current
  property depth

  func constructor() {
    @current = Node("Charly Unit Test Framework", NodeType.Root)
    @tree = @current
    @depth = 0
  }

  func suite(title, callback) {
    @depth += 1

    const new = Node(title, NodeType.Suite)
    const backup = @current
    @current.push(new, @depth)
    @current = new
    callback()
    @current = backup

    @depth -= 1
    self
  }

  func case(title, callback) {
    @depth += 1

    const new = Node(title, NodeType.Test)
    const backup = @current
    @current.push(new, @depth)
    @current = new
    callback()
    @current = backup

    @depth -= 1
    self
  }

  func assert(real, expected) {
    @current.push(
      Assertion(real, expected),
      @depth
    )
    self
  }
}

export = ->(callback) {
  const context = Context()

  callback(
    ->(title, callback) context.suite(title, callback),
    ->(title, callback) context.case(title, callback),
    ->(real, expected) context.assert(real, expected)
  )

  return context.tree
}
