export = func(it) {

  it("runs for the specified count", func(assert) {
    let sum = 0
    let index = 0
    while (index < 500) {
      sum += index
      index += 1
    }

    assert(sum, 124750)
  })

  it("breaks a loop", func(assert) {
    let i = 0
    while (true) {
      if i > 99 {
        break
      }

      i += 1
    }
    assert(i, 100)
  })

}
