const get_node_id = ->() {
  let index = 0
  ->() {
    index += 1
    return index
  }
}()

const NodeType = {
  const Root = 0
  const Suite = 1
  const Test = 2
  const Assertion = 3
}

class Node {
  property id
  property title
  property children
  property type
  property index

  func constructor(title, type) {
    @id = get_node_id()
    @title = title
    @type = type
    @children = []
    @index = 0
  }

  func push(node, depth) {
    node.index = @children.length()
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

  func deep_failed(callback) {
    unless @passed() {
      let path = arguments[1] || []

      if @children.length() == 0 {
        callback(path + self)
      } else {
        @children.each(->(child) {
          child.deep_failed(callback, path + self)
        })
      }

    }
  }
}

class Assertion extends Node {
  property expected
  property real
  property has_passed

  func constructor(real, expected) {
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
