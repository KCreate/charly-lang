export = ->(describe, it, assert) {

  describe("test", ->{

    it("evaluates", ->{
      let ran = false
      func foo() {
        ran = true
      }

      switch foo() {}

      assert(ran, true)
    })

    it("runs the test only once", ->{
      let ran = 0
      func foo() {
        ran += 1
      }

      switch foo() {
        case false {}
        case false {}
        case false {}
        case false {}
        case false {}
      }

      assert(ran, 1)
    })

    it("runs a block if at least 1 value passes", ->{
      let passed

      let obj = {
        func ==(other) {
          other == 25
        }
      }

      switch obj {
        case 0, 5, 10, 15, 20, 25 {
          passed = true
        }
      }

      assert(passed, true)
    })

  })

  describe("branching", ->{

    it("branches to a block", ->{
      let num = 25
      let got = false

      switch num {
        case 20 {
          got = 20
        }

        case 25 {
          got = 25
        }

        case 30 {
          got = 30
        }
      }

      assert(got, 25)
    })

    it("can have multiple values in one case", ->{
      let num = 25
      let got = false

      switch num {
        case 20, 25, 30 {
          got = true
        }
      }

      assert(got, true)
    })

    it("runs the default block", ->{
      let num = 25
      let got = false

      switch num {
        case 20 {
          got = true
        }

        default {
          got = "default was run"
        }
      }

      assert(got, "default was run")
    })

    it("chooses the last default block specified", ->{
      let num = 25
      let got = false

      switch num {
        case 20 {
          got = true
        }

        default {
          got = "default 1 was run"
        }

        default {
          got = "default 2 was run"
        }

        default {
          got = "default 3 was run"
        }
      }

      assert(got, "default 3 was run")
    })

    it("runs duplicate cases", ->{
      let ran = 0

      func foo() {
        ran += 1
        return false
      }

      switch 20 {
        case foo() {}
        case foo() {}
        case foo() {}
        case foo() {}
        case foo() {}
      }

      assert(ran, 5)
    })

    it("returns after the first block that succeeded", ->{
      let ran = 0

      func foo() {
        ran += 1
        return true
      }

      switch true {
        case foo(), foo(), foo() {}
      }

      assert(ran, 1)
    })

    it("returns the value of the first branch to succeed", ->{
      func foo(arg) {
        switch arg {
          case 20 {
            "got 20"
          }

          case 25 {
            "got 25"
          }

          default {
            "got neither 20 or 25"
          }
        }
      }

      let r1 = foo(20)
      let r2 = foo(25)
      let r3 = foo(30)

      assert(r1, "got 20")
      assert(r2, "got 25")
      assert(r3, "got neither 20 or 25")
    })

  })

  describe("scoping", ->{

    it("runs case blocks in a sub-scope", ->{
      let outer = 25

      switch true {
        case true {
          let outer = 50
        }
      }

      assert(outer, 25)
    })

    it("has access to outer scopes", ->{
      let outer = 25

      switch outer = 10 {}

      assert(outer, 10)

      switch true {
        case outer = 20 {}
      }

      assert(outer, 20)
    })

    describe("operator overriding", ->{

      it("runs a overridden equal operator", ->{
        let obj = {
          func ==(other) {
            other == 25
          }
        }

        let passed = false

        switch obj {
          case 25 {
            passed = true
          }
        }

        assert(passed, true)
      })

      it("passes the value as the only argument", ->{
        let got = []
        let obj = {
          func ==() {
            got.push(arguments)
            return false
          }
        }

        switch obj {
          case 25, 30, 35 {}
        }

        assert(got, [[25], [30], [35]])
      })

      it("passes the correct self identifier", ->{
        let got
        let obj = {
          func ==(other) {
            got = [self, other]
            false
          }
        }

        switch obj {
          case 25 {}
        }

        # Almost went mental about this...
        obj.__equal = null

        assert(got[0], obj)
        assert(got[1], 25)
      })

      it("invokes overriden handlers only once", ->{
        let amount = 0
        let obj = {
          func ==(other) {
            amount += 1
          }
        }

        switch obj {
          case 25 {}
        }

        assert(amount, 1)
      })

    })

  })

  describe("control flow", ->{

    it("breaks out of a block", ->{
      let num = 25

      switch num {
        case 25 {
          break
        }

        default {
          num = 50
        }
      }

      assert(num, 25)
    })

    it("breaks out of the default block", ->{
      let num = 25

      switch num {
        default {
          break
          num = 50
        }
      }

      assert(num, 25)
    })

    it("doesn't propagate up", ->{
      let i = 0

      loop {
        switch i {
          case 10 {
            i += 1
            break
          }
        }

        if i == 100 {
          break
        }

        i += 1
      }

      assert(i, 100)
    })

  })

}
