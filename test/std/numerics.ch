export = ->(describe, it, assert) {

  describe("times", ->{

    it("calls the block", ->{
      let amount = 0

      10.times(->{
        amount += 1
      })

      assert(amount, 10)
    })

    it("passes the index property", ->{
      let sum = 0

      10.times(->(index) {
        sum += index
      })

      assert(sum, 45)
    })

    it("n alias", ->{
      let sum = 0

      10.n(->(index) {
        sum += index
      })

      assert(sum, 45)
    })

  })

  describe("upto", ->{

    it("calls the block", ->{
      let start = 10
      let end = 20
      let amount = 0

      start.upto(end, ->{
        amount += 1
      })

      assert(amount, 10)
    })

    it("passes the current number as an argument", ->{
      let start = 10
      let end = 20
      let sum = 0

      start.upto(end, ->(number) {
        sum += number
      })

      assert(sum, 145)
    })

    it("excludes the end", ->{
      let start = 10
      let end = 20
      let highest_number = 0

      start.upto(end, ->(number) {
        highest_number = number
      })

      assert(highest_number, 19)
    })

  })

  describe("downto", ->{

    it("calls the block", ->{
      let start = 20
      let end = 10
      let amount = 0

      start.downto(end, ->{
        amount += 1
      })

      assert(amount, 10)
    })

    it("passes the current number as an argument", ->{
      let start = 20
      let end = 10
      let sum = 0

      start.downto(end, ->(number) {
        sum += number
      })

      assert(sum, 155)
    })

    it("excludes the end", ->{
      let start = 20
      let end = 10
      let lowest_number = 0

      start.downto(end, ->(number) {
        lowest_number = number
      })

      assert(lowest_number, 11)
    })

  })

  describe("abs", ->{

    it("returns the absolute value of a number", ->{
      let nums = [20, -20, 2.9, -1000, 1000]
      let absolutes = nums.map(->$0.abs())

      assert(absolutes, [20, 20, 2.9, 1000, 1000])
    })

  })

  describe("sign", ->{

    it("returns the sign of a number", ->{
      let nums = [200, 20, 1, 0.5, 0, -0, -2, -200]
      let signs = nums.map(->$0.sign())

      assert(signs, [1, 1, 1, 1, 0, 0, -1, -1])
    })

    it("0 and -0 have the same sign", ->{
      assert(0.sign(), -0.sign())
    })

  })

  describe("max", ->{

    it("returns the bigger one of two numbers", ->{
      let nums = [
        [20, 90],
        [-20, 60],
        [90, 43],
        [2.88888, 2.88889]
      ]

      nums = nums.map(->$0[0].max($0[1]))

      let expected = [
        90,
        60,
        90,
        2.88889
      ]

      assert(nums, expected)
    })

  })


  describe("min", ->{

    it("returns the smaller one of two numbers", ->{
      let nums = [
        [20, 90],
        [-20, 60],
        [90, 43],
        [2.88888, 2.88889]
      ]

      nums = nums.map(->$0[0].min($0[1]))

      let expected = [
        20,
        -20,
        43,
        2.88888
      ]

      assert(nums, expected)
    })

  })

  describe("close_to", ->{

    it("returns true if a number is in the given delta", ->{
      assert(5.close_to(6, 2), true)
      assert(5.close_to(6, 1), true)
      assert(5.close_to(6, 0.5), false)
      assert(199.close_to(200, 5), true)
      assert(200.close_to(200.1, 0.05), false)
      assert((-20).close_to(20, 1), false)
    })

  })
}
