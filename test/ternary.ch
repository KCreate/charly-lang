export = ->(it) {
  it("executes ternary if statements", ->(assert) {
    let after_12 = false
    let greeting = after_12 ? "Good night" : "Good morning"

    assert(greeting, "Good morning")
  })

  it("executes nested ternary statements", ->(assert) {
    let result = false ? "hello world" : false ? "hey world" : "whatsup world"

    assert(result, "whatsup world")
  })

  it("can be aligned over multiple lines", ->(assert) {
    let num = 20
    let size = num < 50
    ? "small"
    : "big"

    assert(size, "small")
  })

  it("can be used in lambda literals", ->(assert) {
    let prop = false
    let foo = ->prop ? "true" : "false"

    assert(foo(), "false")
  })
}
