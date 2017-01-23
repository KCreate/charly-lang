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

    it("only runs once", ->{
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

}
