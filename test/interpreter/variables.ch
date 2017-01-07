export = func(describe, it, assert) {

  it("primitives are always passed by value", ->{
    let a = 5
    let b = a
    a = 30

    assert(a, 30)
    assert(b, 5)
  })

  it("creates constants", ->{
    const name = "charly"
    const age = 16
    const weather = "sunny"

    assert(name, "charly")
    assert(age, 16)
    assert(weather, "sunny")
  })

}
