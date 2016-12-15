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

  it("regular while loop returns a value", func(assert) {
    func foo() {
      let a = true
      while a {
        a = false
        30
      }
    }

    assert(foo(), 30)
  })

  it("runs a loop statement", func(assert) {
    let i = 0
    loop {
      if i == 100 {
        break
      }

      i += 1
    }
    assert(i, 100)
  })

  it("runs a until statement", func(assert) {
    let i = 0

    until i == 100 {
      i += 1
    }

    assert(i, 100)
  })
}
