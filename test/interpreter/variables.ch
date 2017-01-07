export = ->(describe, it, assert) {

  it("primitives are always passed by value", ->{
    let a = 5
    let b = a
    a = 30

    assert(a, 30)
    assert(b, 5)
  })

  describe("constants", ->{

    it("creates constants", ->{
      const name = "charly"
      const age = 16
      const weather = "sunny"

      assert(name, "charly")
      assert(age, 16)
      assert(weather, "sunny")
    })

    it("throws when trying to assign to constants", ->{
      const foo = 25

      try {
        foo = 30
      } catch(e) {
        assert(e.message, "Can't assign to foo, it's a constant")
        return
      }

      assert(true, false)
    })

  })

}
