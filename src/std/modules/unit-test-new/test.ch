const UnitTest = require("./lib.ch")
const result = UnitTest(->(describe, it, assert) {

  describe("some behaviour", ->{

    it("does something", ->{

      assert(true, true)
      assert(true, false)

    })

  })

})

print(result)
