export = ->(describe, it, assert) {

  it("runs the alternate block", ->{
    let value = 20

    guard value > 50 {
      assert(true, true)
      return
    }

    assert(false, true)
  })

  it("can check for value existance", ->{
    let box = {}
    box.name = "leonard"

    guard box.name {
      assert(false, true)
    }

    guard box.age {
      assert(true, true)
      return
    }

    // If this is reached, something went wrong
    assert(false, true)
  })

  it("returns a value", ->{
    func foo() {
      guard false {
        30
      }
    }

    assert(foo(), 30)
  })

}
