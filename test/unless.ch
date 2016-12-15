export = ->(it) {
  it("runs the consequent block", ->(assert) {
    let test = false
    let result = false

    unless test {
      result = true
    }

    assert(result, true)
  })

  it("runs the alternate block", ->(assert) {
    let test = true
    let result = false

    unless test {
      result = 25
    } else {
      result = 30
    }

    assert(result, 30)
  })

  it("returns a value", ->(assert) {
    func foo() {
      unless false { 25 } else { 30 }
    }

    func bar() {
      unless true { 25 } else { 30 }
    }

    assert(foo(), 25)
    assert(bar(), 30)
  })
}
