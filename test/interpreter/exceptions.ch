export = ->(describe, it, assert) {

  describe("exceptions", ->{

    it("throws an exception", ->{
      try {
        throw Exception("Something failed")
      } catch (e) {
        assert(e.message, "Something failed")
      }
    })

    it("has a message property", ->{
      try {
        throw Exception("Something failed")
      } catch (e) {
        assert(typeof e.message, "String")
      }
    })

    it("has a trace property", ->{
      try {
        throw Exception("Something failed")
      } catch (e) {
        assert(typeof e.trace, "Array")
        assert(e.trace.length() > 5, true)
      }
    })

  })

  it("throws primitive values", ->{
    try {
      throw 2
    } catch (e) {
      assert(e, 2)
      assert(typeof e, "Numeric")
    }
  })

  it("stops execution of the block", ->{
    try {
      throw 2
      assert(true, false)
    } catch (e) {
      assert(e, 2)
    }
  })

  it("throws exceptions beyond functions", ->{
    func foo() {
      throw Exception("lol")
    }

    try {
      foo()
    } catch (e) {
      assert(e.message, "lol")
    }
  })

  it("throws exceptions inside object constructors", ->{
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

  it("assigns RunTimeErrors a message property", ->{
    try {
      const a = 2
      a = 3
    } catch(e) {
      assert(typeof e.message, "String")
      return
    }

    assert(true, false)
  })

  it("assigns RunTimeErrors a trace property", ->{
    try {
      const a = 2
      a = 3
    } catch(e) {
      assert(typeof e.trace, "Array")
      assert(e.trace.length() > 0, true)
      return
    }

    assert(true, false)
  })

}
