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
      let amount_run = 0

      func obj() {
        amount_run += 1
        return 25;
      }

      switch obj() {
        case 0, 5, 10, 15, 20, 25 {
          passed = true
        }
      }

      assert(amount_run, 1)
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

    it("returns null if break is called", ->{
      let result = switch 25 {
        case 25 {
          break
        }
      }

      assert(result, null)
    })

    it("can return from the parent function", ->{
      func foo() {
        switch 25 {
          case 25 {
            return "hello world"
          }
        }
      }

      let result = foo()

      assert(result, "hello world")
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

    it("captures the break event", ->{
      let i = 0;

      loop {

        // this should behave like a no-op
        // as the break is captured by the switch
        switch 25 {
          case 25 {
            break
          }
        }

        i += 1

        if i == 2 {
          break
        }
      }

      assert(i, 2)
    })

    it("nested loops break correctly", ->{
      let passed = false

      switch 25 {
        case 25 {
          loop {
            break
          }

          passed = true
        }
      }

      assert(passed, true)
    })

    it("lets continue bubble up", ->{
      let sum = 0

      let i = 0
      loop {
        i += 1

        switch i % 2 {
          case 1 {
            continue
          }
        }

        sum += i

        if i == 10 {
          break
        }
      }

      assert(i, 10)
      assert(sum, 30)
    })

  })

  describe("usage as an expression", ->{

    it("assigns to a variable", ->{
      let num = 25

      let result = switch num {
        case 25 {
          "Num is 25"
        }
      }

      assert(result, "Num is 25")
    })

    it("used as a function argument", ->{
      func foo(var) { var }

      let result = foo(switch 25 {
        case 25 {
          "hello world"
        }
      })

      assert(result, "hello world")
    })

  })

}
