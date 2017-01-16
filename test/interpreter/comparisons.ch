export = ->(describe, it, assert) {

  it("compares numerics", ->{
    assert(2 == 2, true)
    assert(20 == 20, true)
    assert(-200 == -200, true)
    assert(2.2323 == 2.2323, true)
    assert(9.666 == 9.666, true)
    assert(-0 == -0, true)
    assert(-0 == 0, true)
  })

  it("compares booleans", ->{
    assert(false == false, true)
    assert(false == true, false)
    assert(true == false, false)
    assert(true == true, true)

    assert(0 == false, false)
    assert(1 == true, false)
    assert(-1 == true, false)
    assert("" == true, false)
    assert("test" == true, false)
    assert([] == true, false)
    assert([1, 2] == true, false)
    assert(null == false, false)
    assert({ let name = "charly" } == true, false)
    assert(func() {} == true, false)
    assert(class Test {} == true, false)
  })

  it("compares strings", ->{
    assert("test" == "test", true)
    assert("" == "", true)
    assert("leeöäüp" == "leeöäüp", true)
    assert("2002" == "2002", true)
    assert("asdlkasd" == "asdlkasd", true)
  })

  it("compares objects", ->{
    assert({} == {}, false)
    assert({ let a = 1 } == {}, false)
    assert({} == { let a = 1 }, false)
    assert({ let a = 1 } == { let a = 1 }, false)

    let me = {
      let name = "charly"
    }

    assert(me == me, true)
    assert(me.name == me.name, true)
  })

  it("compares functions", ->{
    assert(func() {} == func() {}, false)
    assert(func(arg) {} == func(arg) {}, false)
    assert(func(arg) { arg + 1 } == func(arg) { arg + 1 }, false)
    assert(func() { 2 } == func(){ 2 }, false)
  })

  it("compares arrays", ->{
    assert([1, 2, 3] == [1, 2, 3], true)
    assert([] == [], true)
    assert([false] == [false], true)
    assert([[1, 2], "test"] == [[1, 2], "test"], true)

    assert([1] == [1, 2], false)
    assert(["", "a"] == ["a"], false)
    assert([1, 2, 3] == [1, [2], 3], false)
    assert([""] == [""], true)
  })

  it("returns false if two values are not equal", ->{
    assert(2 == 4, false)
    assert(10 == 20, false)
    assert(2.5 == 2.499999, false)
    assert(-20 == 20, false)
    assert(2 == 20, false)

    assert(2 ! 4, true)
    assert(10 ! 20, true)
    assert(2.5 ! 2.499999, true)
    assert(-20 ! 20, true)
    assert(2 ! 20, true)
  })

  describe("> operator", ->{
    assert(2 > 5, false)
    assert(10 > 10, false)
    assert(20 > -20, true)
    assert(4 > 3, true)
    assert(0 > -1, true)

    assert("test" > "test", false)
    assert("whatsup" > "whatsu", true)
    assert("test" > 2, false)
    assert("test" > "tes", true)
    assert(2 > "asdadasd", false)
    assert("" > "", false)
    assert(false > true, false)
    assert(25000 > false, false)
    assert(000.222 > "000.222", false)
    assert(null > "lol", false)
  })

  describe("< operator", ->{
    assert(2 < 5, true)
    assert(10 < 10, false)
    assert(20 < -20, false)
    assert(4 < 3, false)
    assert(0 < -1, false)

    assert("test" < "test", false)
    assert("whatsup" < "whatsu", false)
    assert("test" < 2, false)
    assert("test" < "tes", false)
    assert(2 < "asdadasd", false)
    assert("" < "", false)
    assert(false < true, false)
    assert(25000 < false, false)
    assert(000.222 < "000.222", false)
    assert(null < "lol", false)
  })

  describe(">= operator", ->{
    assert(5 >= 2, true)
    assert(10 >= 10, true)
    assert(20 >= 20, true)
    assert(4 >= 3, true)
    assert(0 >= -1, true)

    assert("test" >= "test", true)
    assert("whaaatsup" >= "whatsup", true)
    assert("lol" >= "lol", true)
    assert("abc" >= "def", true)
    assert("small" >= "reaaalllybiiig", false)
  })

  describe("<= operator", ->{
    assert(2 <= 5, true)
    assert(10 <= 10, true)
    assert(20 <= -20, false)
    assert(4 <= 3, false)
    assert(200 <= 200, true)

    assert("test" <= "test", true)
    assert("whaaatsup" <= "whatsup", false)
    assert("lol" <= "lol", true)
    assert("abc" <= "def", true)
    assert("small" <= "reaaalllybiiig", true)
  })

  describe("not operator", ->{


    it("inverts a value", ->{
      assert(!false, true)
      assert(!true, false)
      assert(!0, false)
      assert(!25, false)
      assert(!"test", false)
    })

  })

  describe("AND comparison", ->{
    assert(true && true, true)
    assert(true && false, false)
    assert(false && true, false)
    assert(false && false, false)
  })

  describe("OR comparison", ->{
    assert(true || true, true)
    assert(true || false, true)
    assert(false || true, true)
    assert(false || false, false)
  })

  describe("conditional assignment", ->{
    let a = 25
    let b = null
    let c = false

    let d

    d = a || b
    assert(d.typeof(), "Numeric")

    d = b || c
    assert(d.typeof(), "Boolean")

    d = b || a
    assert(d.typeof(), "Numeric")

    d = c || b
    assert(d.typeof(), "Null")
  })

  describe("null values", ->{
    assert(25 ! null, true)
    assert(null ! null, false)
    assert(null == null, true)
    assert(null == false, false)
    assert(null == true, false)
    assert(null ! false, true)
    assert(null ! true, true)
  })

}
