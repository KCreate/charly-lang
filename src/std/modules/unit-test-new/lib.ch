const Context = require("./context.ch")
const TestVisitor = require("./visitor.ch")

export = ->(callback) {
  const visitor = TestVisitor(write, print)
  const context = Context(visitor)

  callback(
    ->(title, callback) context.suite(title, callback),
    ->(title, callback) context.case(title, callback),
    ->(real, expected) context.assert(real, expected)
  )

  return context.tree
}
