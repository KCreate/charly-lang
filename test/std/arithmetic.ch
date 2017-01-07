export = ->(describe, it, assert) {

  it("adds numbers", ->{
    assert(2 + 2, 4)
    assert(10 + -50, -40)
    assert(2.5 + 9.7, 12.2)
    assert(-20.5 + 20.5, 0)
    assert(999.999 + 999.999, 1999.998)
  })

  it("subtracts numbers", ->{
    assert(20 - 5, 15)
    assert(3 - 3, 0)
    assert(-5 - 9, -14)
    assert(-0 - -0, 0)
    assert(-20 - -90, 70)
  })

  it("multiplies numbers", ->{
    assert(2 * 0, 0)
    assert(2 * 5, 10)
    assert(3 * 25, 75)
    assert(9 * -50, -450)
    assert(0.5 * 5, 2.5)
  })

  it("divides numbers", ->{
    assert(5 / 0, NAN)
    assert(5 / -2, -2.5)
    assert(10 / 4, 2.5)
    assert(100 / 8, 12.5)
    assert(1 / 2, 0.5)
  })

  it("modulus operator", ->{
    assert(6 % 3, 0)
    assert(0 % 0, NAN)
    assert(177 % 34, 7)
    assert(700 % 200, 100)
    assert(20 % 3, 2)
  })

  it("pow operator", ->{
    assert(2**8, 256)
    assert(50**3, 125000)
    assert(2**4, 16)
    assert(50**1, 50)
    assert(50**0, 1)
  })

  it("does AND assignments", ->{
    let a = 20

    a += 1
    assert(a, 21)

    a -= 1
    assert(a, 20)

    a *= 20
    assert(a, 400)

    a /= 20
    assert(a, 20)

    a %= 6
    assert(a, 2)

    a **= 3
    assert(a, 8)
  })

}
