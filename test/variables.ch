export = func(it) {

  it("assigns a value to a variable", func(assert) {
    let my_string = "Hello World"
    let my_number = 25
    let my_bool = false
    let my_array = [1, "Whatsup", false]
    let my_null = null

    assert(my_string, "Hello World")
    assert(my_number, 25)
    assert(my_bool, false)
    assert(my_array[1], "Whatsup")
    assert(my_null, null)
  })

  it("resolves variables in calculations", func(assert) {
    let first_number = 25
    let second_number = 5

    assert(first_number + second_number, 30)
  })

  it("primitives are always passed by value", func(assert) {
    let a = 5
    let b = a
    a = 30

    assert(a, 30)
    assert(b, 5)
  })

  it("creates constants", func(assert) {
    const name = "charly"
    const age = 16
    const weather = "sunny"

    assert(name, "charly")
    assert(age, 16)
    assert(weather, "sunny")
  })

}
