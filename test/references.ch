export = ->(it) {
  it("creates references to variables", func(assert) {
    let string = "hello "
    let reference = &string

    string += "world"

    assert(string, "hello world")
    assert(&reference, "hello world")
    assert(reference.to_s(), "Reference:String")

    &reference = 25

    assert(string, 25)
    assert(reference.to_s(), "Reference:Numeric")
  })

  it("dereferences correctly", func(assert) {
    let string = "test"
    let reference= &string

    assert(reference.typeof(), "Reference")

    reference = 25

    assert(string, "test")
    assert(reference, 25)
  })

  it("passes references to functions", func(assert) {
    let string = "test"
    let reference = &string

    func foo(arg) {
      &arg = 25
    }

    foo(reference)

    assert(string, 25)
  })

  it("references closured variables from functions", func(assert) {

    func counter() {
      let value = 0
      &value
    }

    let value = counter()

    &value += 10
    &value += 10

    assert(value.value(), 20)
  })

  it("references variables from deleted closures", func(assert) {
    func counter() {
      let value = 0
      &value
    }

    let value = counter()

    counter = null

    &value += 10
    &value += 10

    assert(value.value(), 20)
  })

  it("puts references into objects", func(assert) {
    let string = "test"
    let container = {
      let string = &string
    }

    string = "hello world"

    assert(container.string.value(), "hello world")

    let reference = container.string

    assert(&reference, "hello world")

    &reference = 25

    assert(string, 25)
    assert(container.string.value(), 25)
  })

  it("iterates over an array of references", func(assert) {
    let n = 0
    let r = &n
    let nums = []

    5.times(->{
      nums.push(&r)
      n += 1
    })

    assert(nums, [0, 1, 2, 3, 4])
  })

  it("compares references", func(assert) {
    let n1 = 1
    let n2 = 2

    let r1 = &n1
    let r2 = &n2

    assert(r1 == r2, false)

    r2 = &n1

    assert(r1 == r2, true)
  })

  it("can't overwrite a constant referenced value", func(assert) {
    const num = 25
    let ref = &num

    try {
      &ref = 30
    } catch(e) {
      assert(true, true)
      return
    }

    assert(false, true)
  })

  it("creates references to functions", func(assert) {
    func foo() {
      25
    }

    func bar() {
      50
    }

    let ref = &foo

    assert(&ref(), 25)

    &ref = bar

    assert(&ref(), 50)
  })
}
