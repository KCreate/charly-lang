const UnitTest = require("unit-test-new")
const Result = UnitTest(->(describe, it, assert, context) {

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
    assert(false, true)
  })

})

UnitTest.display_result(Result, io.exit)
