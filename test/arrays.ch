export = func(it) {

  it("does member expressions", func(assert) {
    let nums = [1, 2, 3, 4]

    assert(nums[0], 1)
    assert(nums[3], 4)
    assert(nums[10], null)
    assert(nums[-10], null)
  })

  it("does multilevel member expressions", func(assert) {
    let nums = [[1, 2], [3, 4, "test"], [5, 6]]

    assert(nums[0][1], 2)
    assert(nums[2][0], 5)
    assert(nums[1][2], "test")
    assert(nums[1][-2], null)
  })

  it("write to an index", func(assert) {
    let nums = [1, 2, 3, 4]

    nums[0] = 2
    nums[1] = 3
    nums[2] = 4

    assert(nums == [2, 3, 4, 4], true)
  })

  it("writes to a nested index", func(assert) {
    let nums = [1, 2, [3, 4]]

    nums[0] = 2
    nums[1] = 3
    nums[2][0] = 4
    nums[2][1] = 5

    assert(nums == [2, 3, [4, 5]], true)
  })

  it("gives back the length", func(assert) {
    assert([].length(), 0)
    assert([1, 2].length(), 2)
    assert([1, 2, [3, 4]].length(), 3)
    assert([1, 2, 3, [4, 5]][3].length(), 2)
    assert(["test"].length(), 1)
  })

  it("iterates via each", func(assert) {
    let got = []
    let nums = [1, 2, 3, 4]

    nums.each(func(v) {
      got.push(v)
    })

    assert(got == nums, true)
  })

  it("receives the size of the original array", func(assert) {
    let _size = 0
    let nums = [1, 2, 3, 4]

    nums.each(->(item, index, size) {
      _size = size
    })

    assert(_size, 4)
  })

  it("maps over an array", func(assert) {
    let nums = [1, 2, 3, 4]

    nums = nums.map(func(n) {
      n**2
    })

    assert(nums == [1, 4, 9, 16], true)
  })

  it("converts all items to strings", func(assert) {
    let nums = [1, 2, 3, 4]

    nums = nums.all_to_s()

    assert(nums == ["1", "2", "3", "4"], true)
  })

  it("creates a new array using Array.of_size", func(assert) {
    let new_array = Array.of_size(100, "whaaaaaaaaaaaaaaaaaat")
    assert(new_array.length(), 100)
  })

  it("appends to the end", func(assert) {
    let nums = [1, 2]

    nums.push(3)
    nums.push(4)
    nums.push(5)
    nums.push(6)

    assert(nums.length(), 6)
    assert(nums == [1, 2, 3, 4, 5, 6], true)
  })

  it("append to the beginning", func(assert) {
    let nums = [1, 2]

    nums.unshift(3)
    nums.unshift(4)
    nums.unshift(5)
    nums.unshift(6)

    assert(nums.length(), 6)
    assert(nums == [6, 5, 4, 3, 1, 2], true)
  })

  it("pops", func(assert) {
    let nums = [1, 2, 3, 4]

    let results = []

    results.push(nums.pop())
    results.push(nums.pop())
    results.push(nums.pop())
    results.push(nums.pop())

    assert(results.length(), 4)
    assert(results, [4, 3, 2, 1])
  })

  it("shifts", func(assert) {
    let nums = [4, 3, 2, 1]

    let results = []

    results.push(nums.shift())
    results.push(nums.shift())
    results.push(nums.shift())
    results.push(nums.shift())

    assert(results.length(), 4)
    assert(results, [4, 3, 2, 1])
  })

  it("inserts at a given index", func(assert) {
    let nums = [1, 2]

    nums.insert(0, 3)
    nums.insert(1, 4)
    nums.insert(-200, 5)
    nums.insert(1000, 6)
    nums.insert(4, 7)

    assert(nums.length(), 7)
    assert(nums == [5, 3, 4, 1, 7, 2, 6], true)
  })

  it("deletes a given index", func(assert) {
    let nums = [1, 2, 3, 4, 5]

    nums.delete(0)
    nums.delete(3)
    nums.delete(1)

    assert(nums.length(), 2)
    assert(nums == [2, 4], true)
  })

  it("returns the first element", func(assert) {
    assert([].first(), null)
    assert([1, 2].first(), 1)
    assert([[1]].first()[0], 1)
  })

  it("returns the last element", func(assert) {
    assert([].last(), null)
    assert([1, 2, 3].last(), 3)
    assert([1].last(), 1)
    assert([[1, 2]].last()[1], 2)
  })

  it("concatenates two arrays", func(assert) {
    let num1 = [1, 2]
    let num2 = [3, 4]
    let num3 = num1 + num2

    assert(num3 == [1, 2, 3, 4], true)
  })

  it("flattens an array", func(assert) {
    let num = [1, [2, [3], 4], 5, [[6], 7], 8]

    num = num.flatten()

    assert(num.length(), 8)
    assert(num == [1, 2, 3, 4, 5, 6, 7, 8], true)
  })

  it("filters an array", func(assert) {
    let nums = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]

    nums = nums.filter(func(e, i) {
      if (e <= 5) {
        (i % 2) == 0
      } else {
        false
      }
    })

    assert(nums.length(), 3)
    assert(nums == [1, 3, 5], true)
  })

  it("reverses an array", func(assert) {
    let nums = [1, 2, 3, 4]

    nums = nums.reverse()

    assert(nums == [4, 3, 2, 1], true)
  })

  it("returns the index of an element", func(assert) {
    let nums = [1, "test", "hello", false]

    assert(nums.index_of(2), -1)
    assert(nums.index_of(1), 0)
    assert(nums.index_of("test"), 1)
    assert(nums.index_of("hellö"), -1)
    assert(nums.index_of("hello"), 2)
    assert(nums.index_of(false), 3)
    assert(nums.index_of(true), -1)
  })

  it("checks if the array is empty", func(assert) {
    assert([].empty(), true)
    assert([1].empty(), false)
    assert([1, 2].empty(), false)
    assert(["test"].empty(), false)
    assert([null].empty(), false)
  })

  it("joins an array", func(assert) {
    assert([1, 2, 3, 4].join("-"), "1-2-3-4")
    assert(["hello", "world", "whats", "up"].join("\n"), "hello\nworld\nwhats\nup")
    assert(["hello", -25.9, "test", [1, 2]].join(""), "hello-25.9test[1, 2]")
  })

  it("gives back a range from an array", func(assert) {
    assert([1, 2, 3, 4].range(0, 2), [1, 2])
    assert([1, 2, 3, 4].range(2, 4), [3, 4])
    assert([1, 2, 3, 4].range(4, 0), [1, 2, 3, 4])
    assert([1, 2, 3, 4].range(0, 0), [])
    assert([1, 2, 3, 4].range(0, 500), [1, 2, 3, 4])
    assert([].range(0, 1), [])
  })

  it("sorts numbers", func(assert) {
    const nums = [900, 20, -29, -100]
    const sorted = nums.sort(func(left, right) {
      left < right
    })

    assert(sorted, [-100, -29, 20, 900])
  })

}
