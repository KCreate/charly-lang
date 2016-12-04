export = func(it) {

  it("throws an exception", func(assert) {
    try {
      throw Exception("Something failed")
    } catch (e) {
      assert(e.message, "Something failed")
    }
  })

  it("throws primitive values", func(assert) {
    try {
      throw 2
    } catch (e) {
      assert(e, 2)
      assert(e.typeof(), "Numeric")
    }
  })

  it("stops execution of the block", func(assert) {
    try {
      throw 2
      assert(true, false)
    } catch (e) {
      assert(e, 2)
    }
  })

  it("throws exceptions beyond functions", func(assert) {
    func foo() {
      throw Exception("lol")
    }

    try {
      foo()
    } catch (e) {
      assert(e.message, "lol")
    }
  })

  it("throws exceptions inside object constructors", func(assert) {
    class Foo {
      func constructor() {
        throw 2
      }
    }

    try {
      let a = Foo()
    } catch (e) {
      assert(e, 2)
    }
  })

  it("assigns RunTimeErrors a message property", func(assert) {
    try {
      const a = 2
      a = 3
    } catch(e) {
      assert(e.message.typeof(), "String")
      return
    }

    assert(true, false)
  })

  it("assigns RunTimeErrors a trace property", func(assert) {
    try {
      const a = 2
      a = 3
    } catch(e) {
      assert(e.trace.typeof(), "Array")
      assert(e.trace.length() > 0, true)
      return
    }

    assert(true, false)
  })

}
