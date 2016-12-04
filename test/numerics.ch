export = func(it) {

  it("implicitly casts integers to floats", func(assert) {
    assert(2 == 2.0, true)
    assert(2000.0000 == 2000, true)
    assert(-289 == -289.0, true)
    assert(0 == 0.0, true)
    assert(0000000000.000000000 == 0, true)
  })

  it("calls times", func(assert) {
    let sum = 0
    500.times(func(i) {
      sum += i
    })

    assert(sum, 124750)
  })

  it("calls downto", func(assert) {
    let sum = 0
    10.downto(1, func(n) {
      sum += n
    })

    assert(sum, 54)
  })

  it("calls upto", func(assert) {
    let sum = 0
    5.upto(10, func(n) {
      sum += n
    })

    assert(sum, 35)
  })

}
