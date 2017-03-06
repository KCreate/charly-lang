export = ->(describe, it, assert) {

  describe("evaluation", ->{

    it("returns the result of the calculation", ->{
      let source = "2 + 3 / 6"
      let result = eval(source, {})

      assert(result, 2.5)
    })

    it("sets variables in the context object", ->{
      let source = "
        let a = 25
        let b = 50
        let c = a + b
      "

      let context = {}
      let result = eval(source, context)

      assert(context.a, 25)
      assert(context.b, 50)
      assert(context.c, 75)
    })

    it("can throw exceptions", ->{
      let source = "throw Exception(\"Something failed!\")"

      try {
        eval(source, {})
      } catch(e) {
        assert(e.message, "Something failed!")
        assert(typeof e.trace, "Array")

        return
      }

      assert(true, false)
    })

    it("has access to the prelude", ->{
      eval("String.methods.foo = 25", {})

      assert(String.methods.foo, 25)

      String.methods.foo = null
    })

  })

}
