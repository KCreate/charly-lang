const UnitTest = require("unit-test-new")
UnitTest(->(describe, it, assert) {

  describe("some functionality", ->{

    it("should do something", ->{
      assert(true, true)
      assert(true, true)
      assert(true, false)
      assert(true, false)

    })

  })

})
