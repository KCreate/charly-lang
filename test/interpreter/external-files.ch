export = ->(describe, it, assert) {

  describe("require", ->{

    it("loads an internal module", ->{
      const Math = require("math")

      assert(typeof Math, "Object")
      assert(typeof Math.rand, "Function")
      assert(typeof Math.sin(25), "Numeric")
    })

    it("includes files", ->{
      const module = require("./require-test/module.ch")

      assert(module.num, 25)
      assert(typeof module.foo, "Function")
      assert(module.foo(), "I am foo")
      assert(module.bar(1, 2), 3)

      let Person = module.Person

      assert(typeof Person, "Class")

      let leonard = Person("Leonard", 2000)
      let bob = Person("Bob", 1990)

      assert(typeof leonard, "Object")
      assert(typeof bob, "Object")

      assert(leonard.name, "Leonard")
      assert(leonard.birthyear, 2000)

      assert(leonard.greeting(), "Leonard was born in 2000.")
    })

  })

  describe("stack traces", ->{

    it("passes the current stack to the included file", ->{
      const foo = require("./require-test/foo.ch")

      try {
        foo.foo(->foo.bar())
      } catch(e) {
        assert(typeof e.trace, "Array")
        assert(e.trace.length() > 20, true)
      }
    })

  })

}
