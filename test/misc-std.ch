export = func(it) {

  it("returns the type() of a variable", func(assert) {
    assert(false.typeof(), "Boolean")
    assert(true.typeof(), "Boolean")
    assert("test".typeof(), "String")
    assert(25.typeof(), "Numeric")
    assert(25.5.typeof(), "Numeric")
    assert([1, 2, 3].typeof(), "Array")
    assert((class Test {}).typeof(), "Class")
    assert((func() {}).typeof(), "Function")
    assert({}.typeof(), "Object")
    assert(null.typeof(), "Null")
  })

  it("casts string to numeric", func(assert) {
    assert("25".to_n(), 25)
    assert("25.5".to_n(), 25.5)
    assert("0".to_n(), 0)
    assert("100029".to_n(), 100029)
    assert("-89.2".to_n(), -89.2)

    assert("hello".to_n(), NAN)
    assert("25test".to_n(), 25)
    assert("ermokay30".to_n(), NAN)
    assert("-2.25this".to_n(), -2.25)

    assert("123.45e2".to_n(), 12345)
    assert("2e5".to_n(), 200_000)
    assert("25e-5".to_n(), 0.00025)
    assert("9e-2".to_n(), 0.09)
  })

  it("pipes an array to different functions", func(assert) {
    let res1
    let res2
    let res3

    func setRes1(v) {
      res1 = v
    }

    func setRes2(v) {
      res2 = v
    }

    func setRes3(v) {
      res3 = v
    }

    5.pipe(setRes1, setRes2, setRes3)

    assert(res1, 5)
    assert(res2, 5)
    assert(res3, 5)
  })

  it("transforms an array", func(assert) {
    func reverse(array) {
      array.reverse()
    }

    func addOne(array) {
      array.map(func(e) { e + 1 })
    }

    func multiplyByTwo(array) {
      array.map(func(e) { e * 2 })
    }

    const nums = [1, 2, 3, 4, 5]
    const result = nums.transform(multiplyByTwo, reverse, addOne)
    assert(result, [11, 9, 7, 5, 3])
  })

}
