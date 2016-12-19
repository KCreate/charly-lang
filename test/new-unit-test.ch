const UnitTest = require("unit-test-new")
UnitTest(->(describe, it, assert) {

  describe("some functionality", ->{

    it("should do something", ->{
      assert(true, true)
      assert(true, true)
      assert(true, false)
      assert(true, false)

    })

    it("does something else", ->{
      assert(true, true)
    })

  })

  describe("another functionality", ->{
    assert(false, false)
  })

})
