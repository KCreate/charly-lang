export = ->(it) {
  it("runs the alternate block", ->(assert) {
    let value = 20

    guard value > 50 {
      assert(true, true)
      return
    }

    assert(false, true)
  })

  it("can check for value existance", ->(assert) {
    let box = {}
    box.name = "leonard"

    guard box.name {
      assert(false, true)
    }

    assert(true, true)
  })

  it("returns a value", ->(assert) {
    func foo() {
      guard false {
        30
      }
    }

    assert(foo(), 30)
  })
}
