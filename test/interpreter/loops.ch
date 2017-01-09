export = ->(describe, it, assert) {

  describe("while", ->{

    it("while statement runs in a new scope each time", ->{
      let i = 0
      while i < 10 {
        let num = 0 // If the same scope is reused this would crash
        i += 1
      }

      assert(i, 10)
    })

    it("runs for the specified count", ->{
      let sum = 0
      let index = 0
      while (index < 500) {
        sum += index
        index += 1
      }

      assert(sum, 124750)
    })

    it("breaks a loop", ->{
      let i = 0
      while (true) {
        if i > 99 {
          break
        }

        i += 1
      }
      assert(i, 100)
    })

    it("regular while loop returns a value", ->{
      func foo() {
        let a = true
        while a {
          a = false
          30
        }
      }

      assert(foo(), 30)
    })

  })

  describe("continue", ->{

    it("continues to the end of a loop", ->{
      let i = 0
      let sum = 0
      while i < 50 {
        if i % 2 == 0 {
          i += 1
          continue
        }

        sum += 1
        i += 1
      }

      assert(sum, 25)
    })

    it("can be deeply nested", ->{
      let i = 0
      let sum = 0

      while i < 50 {
        if i > 10 {
          if i > 20 {
            if i > 30 {
              i += 1
              continue
            }
          }
        }

        i += 1
        sum += 1
      }

      assert(sum, 31)
    })

  })

  describe("until", ->{

    it("until statement runs in a new scope each time", ->{
      let i = 0
      until i > 9 {
        let num = 0 // If the same scope is reused this would crash
        i += 1
      }

      assert(i, 10)
    })

    it("runs a until statement", ->{
      let i = 0

      until i == 100 {
        i += 1
      }

      assert(i, 100)
    })

    it("until loop returns a value", ->{
      func foo() {
        let a = false
        until a {
          a = true
          30
        }
      }

      assert(foo(), 30)
    })

  })

  describe("loop", ->{

    it("loop statement runs in a new scope each time", ->{
      let i = 0
      loop {
        if i > 9 {
          break
        }

        let num = 0 // If the same scope is reused this would crash
        i += 1
      }

      assert(i, 10)
    })

    it("runs a loop statement", ->{
      let i = 0
      loop {
        if i == 100 {
          break
        }

        i += 1
      }
      assert(i, 100)
    })

  })

}
