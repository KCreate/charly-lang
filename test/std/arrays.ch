const Math = require("math")

export = ->(describe, it, assert) {

  describe("member expressions", ->{
    let nums = [1, 2, 3, 4]

    it("returns a value at a given index", ->{
      assert(nums[0], 1)
      assert(nums[1], 2)
      assert(nums[2], 3)
      assert(nums[3], 4)
    })

    it("returns null for values out of bounds", ->{
      assert(nums[100].typeof(), "Null")
      assert(nums[-20].typeof(), "Null")
    })

    describe("multilevel expressions", ->{
      let nums = [[1, 2], [3, 4, "test"], [5, 6]]

      it("returns a nested array", ->{
        assert(nums[0][1], 2)
        assert(nums[2][0], 5)
        assert(nums[1][2], "test")
        assert(nums[1][-2], null)
      })

    })

  })

  describe("writing", ->{
    let nums = [1, 2, 3, 4]

    it("writes to an index", ->{
      nums[0] = 2
      nums[1] = 3
      nums[2] = 4
      nums[3] = 5

      assert(nums, [2, 3, 4, 5])
    })

    it("writes to a nested index", ->{
      let nums = [1, 2, 3, [4, 5, 6]]

      nums[3][2] = 5000
      assert(nums[3][2], 5000)
    })

    it("throws when writing out of bounds", ->{
      let nums = [1, 2, 3, 4]

      try {
        nums[200] = 5
      } catch(e) {
        assert(e.message, "Index out of bounds. Size is 4, index is 200")
        return
      }

      assert(true, false)
    })

  })

  it("returns the length of an array", ->{
    let arr1 = []
    let arr2 = [1, 2, 3, 4]
    let arr3 = [null, null, null, 5]

    assert(arr1.length(), 0)
    assert(arr2.length(), 4)
    assert(arr3.length(), 4)
  })

  describe("each", ->{

    describe("iteratation", ->{
      let nums = [1, 2, 3, 4]

      it("returns each value of the array", ->{
        let got = []

        nums.each(->(value) {
          got.push(value)
        })

        assert(got, [1, 2, 3, 4])
      })

      it("passes the index of the value", ->{
        let sum = 0

        nums.each(->sum += $1)

        assert(sum, 6)
      })

      it("receives the size of the array", ->{
        let size_sum = 0

        nums.each(->size_sum += $2)

        assert(size_sum, 16)
      })

      it("returns the original array", ->{
        let got = nums.each(->{
          null
        })

        assert(got, nums)
      })

    })

  })

  describe("map", ->{

    it("creates a new array", ->{
      let nums = [1, 2, 3, 4]
      let squared = nums.map(->(number) {
        number ** 2
      })

      assert(squared, [1, 4, 9, 16])
    })

    it("takes a function", ->{
      let nums = [1, 2, 3, 4]

      func myOperation(number, index) {
        [number, index]
      }

      let got = nums.map(myOperation)

      assert(got, [[1, 0], [2, 1], [3, 2], [4, 3]])
    })

    it("passes the element, index, and size", ->{
      let nums = [1]
      let got

      nums.map(->got = arguments)

      assert(got, [1, 0, 1])
    })

  })

  describe("copy", ->{

    it("leaves the original untouched", ->{
      let nums = [1, 2, 3, 4]
      let copy = nums.copy()

      assert(nums, copy)

      nums[0] = 200

      assert(copy[0], 1)
    })

    it("copies objects by reference", ->{
      let objects = [{
        let name = "test"
      }]

      let copy = objects.copy()

      assert(objects[0].name, "test")
      assert(copy[0].name, "test")

      objects[0].name = "it changed"
      assert(copy[0].name, "it changed")
    })

  })

  describe("all_to_s", ->{
    let nums = [1, 2, 3, 4]

    it("returns an array", ->{
      let strings = nums.all_to_s()
      assert(strings.typeof(), "Array")
    })

    it("leaves the original untouched", ->{
      let strings = nums.all_to_s()

      assert(nums[0].typeof(), "Numeric")
    })

    it("respects the to_s method", ->{
      let objects = [{
        func to_s() {
          "i am an object"
        }
      }]

      let strings = objects.all_to_s()
      assert(strings[0], "i am an object")
    })

  })

  describe("Array.of_size", ->{
    it("has the given size", ->{
      let arr = Array.of_size(20, null)
      assert(arr.length(), 20)
    })

    it("fills it with a given element", ->{
      let arr = Array.of_size(20, "test")
      assert(arr[4], "test")
      assert(arr.length(), 20)
    })
  })

  describe("adding and removing elements", ->{

    describe("adding elements", ->{

      it("appends to the end", ->{
        let arr = [1, 2, 3, 4]
        arr.push(5)
        arr.push(6)
        arr.push(7)

        assert(arr.length(), 7)
        assert(arr[6], 7)
        assert(arr, [1, 2, 3, 4, 5, 6, 7])
      })

      it("appends to the beginning", ->{
        let arr = [1, 2, 3, 4]
        arr.unshift(5)
        arr.unshift(6)
        arr.unshift(7)

        assert(arr.length(), 7)
        assert(arr[6], 4)
        assert(arr, [7, 6, 5, 1, 2, 3, 4])
      })

      it("inserts at a given index", ->{
        let nums = [1, 2]

        nums.insert(0, 3)
        nums.insert(1, 4)
        nums.insert(-200, 5)
        nums.insert(1000, 6)
        nums.insert(4, 7)

        assert(nums.length(), 7)
        assert(nums == [5, 3, 4, 1, 7, 2, 6], true)
      })

      describe("index insertion", ->{

        it("inserts at an existing index", ->{
          let nums = [1, 2]

          nums.insert(0, 3)
          nums.insert(2, 5)

          assert(nums, [3, 1, 5, 2])
        })

        it("insert out of bounds", ->{
          let nums = [1, 2, 3]

          nums.insert(200, 4)
          nums.insert(-900, 0)

          assert(nums, [0, 1, 2, 3, 4])
        })

      })

    })

    describe("removing elements", ->{

      it("removes from the end", ->{
        let arr = [1, 2, 3, 4]
        arr.pop()
        arr.pop()
        arr.pop()

        assert(arr, [1])
      })

      it("removes from the beginning", ->{
        let arr = [1, 2, 3, 4]
        arr.shift()
        arr.shift()
        arr.shift()

        assert(arr, [4])
      })

      describe("index deletion", ->{

        it("deletes at an existing index", ->{
          let nums = [1, 2, 3, 4, 5]

          nums.delete(0)
          nums.delete(3)
          nums.delete(1)

          assert(nums, [2, 4])
        })

        it("deletes out of bounds", ->{
          let nums = [1, 2, 3, 4, 5]

          nums.delete(200)
          nums.delete(200)
          nums.delete(200)

          assert(nums, [1, 2])
        })

      })

    })

  })

  describe("first", ->{

    it("returns the first element", ->{
      let nums = [1, 2, 3]
      let value = nums.first()

      assert(value, 1)
    })

    it("returns null on an empty array", ->{
      let nums = []
      let value = nums.first()

      assert(value.typeof(), "Null")
    })

  })

  describe("last", ->{

    it("returns the last element", ->{
      let nums = [1, 2, 3]
      let value = nums.last()

      assert(value, 3)
    })

    it("returns null on an empty array", ->{
      let nums = []
      let value = nums.last()

      assert(value.typeof(), "Null")
    })

  })

  describe("array concatenation", ->{

    it("concats two arrays", ->{
      let num1 = [1, 2]
      let num2 = [3, 4]
      let num3 = num1 + num2

      assert(num3, [1, 2, 3, 4])
    })

    it("copies objects and arrays by reference", ->{
      let arrays = [[1, 2], [3, 4]]
      let objects = [{
        let name = "charly"
      }, {
        let name = "test"
      }]

      let concat = arrays + objects

      arrays[0][0] = 200

      assert(concat[0][0], 200)

      objects[0].name = "it changed"
      objects[1].name = "it changed too"

      assert(concat[2].name, "it changed")
      assert(concat[3].name, "it changed too")
    })

    it("concats empty arrays", ->{
      let arr = [] + []

      assert(arr, [])
      assert(arr.length(), 0)
    })

  })

  it("reverses an array", ->{
    let nums = [1, 2, 3, 4]
    let rev = nums.reverse()

    assert(rev, [4, 3, 2, 1])
    assert(nums, [1, 2, 3, 4])
  })

  it("filters an array", ->{
    let nums = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]

    let filtered = nums.filter(->(number, index) {
      if number <= 5 {
        index % 2 == 0
      } else {
        false
      }
    })

    assert(filtered.length(), 3)
    assert(filtered, [1, 3, 5])
  })

  describe("sorting", ->{

    it("sorts an array of numbers", ->{
      let nums = [20, -20, 8, 8.1, 200]
      let sorted = nums.sort()

      assert(sorted, [-20, 8, 8.1, 20, 200])
    })

    it("sorts an array of strings", ->{
      let names = [
        "Charly",
        "Peter",
        "Alice",
        "Bob",
        "John"
      ]

      let sorted = names.sort()

      assert(sorted, ["Bob", "John", "Peter", "Alice", "Charly"])
    })

    it("sorts an empty array", ->{
      let empty = []
      let sorted = empty.sort()

      assert(sorted, [])
    })

    // Arrays larger than 20 elements are sorted using quick-sort
    // generate some fake numbers and check if they are being correctly
    // sorted
    it("sorts using quick-sort", ->{
      let nums = Array.of_size(100, null)
      nums = nums.map(Math.rand)

      nums = nums.sort()

      let invalid = false

      nums.each(->(item, index) {
        const next = nums[index + 1]

        if item > next && !invalid {
          invalid = true
        }
      })

      assert(invalid, false)
    })

  })

  it("checks if an array is empty", ->{
    assert([].empty(), true)
    assert([1, 2].empty(), false)
    assert([null].empty(), false)
    assert([""].empty(), false)
    assert([{}].empty(), false)
    assert([[]].empty(), false)
  })

  describe("search", ->{

    it("finds a number", ->{
      let nums = [1, 2, 3, 4]

      assert(nums.index_of(1), 0)
      assert(nums.index_of(2), 1)
      assert(nums.index_of(3), 2)
      assert(nums.index_of(4), 3)
      assert(nums.index_of(100), -1)
      assert(nums.index_of(true), -1)
    })

  })

  describe("join", ->{

    it("joins an array of strings", ->{
      let lines = ["Hello", "World", "!"]
      let message = lines.join("\n")

      assert(message, "Hello\nWorld\n!")
    })

    it("joins values of mixed types", ->{
      let items = [
        "test",
        25,
        [1, 2],
        false,
        null,
        func myfunction() {},
        class Test {},
        { let name = "Bob" }
      ]

      let message = items.join("")

      assert(message, "test25[1, 2]falsenullFunction:0Class:0{\n  name: Bob\n}")
    })

    it("invokes the to_s method of objects", ->{
      let objects = [{
        func to_s() {
          "This is the object"
        }
      }, "test"]

      let message = objects.join(" ")

      assert(message, "This is the object test")
    })

  })

  describe("range", ->{

    it("returns an empty array if the array is emtpy", ->{
      let arr = []
      let items = arr.range(0, 2)

      assert(items, [])
    })

    it("returns a range", ->{
      let arr = [1, 2, 3, 4, 5]
      let items = arr.range(2, 3)

      assert(items, [3, 4, 5])
    })

    it("doesn't append null after the index is out of bounds", ->{
      let arr = [1, 2, 3]
      let items = arr.range(0, 100)

      assert(items, [1, 2, 3])
    })

    it("returns an empty array if amount is zero", ->{
      let arr = [1, 2, 3]
      let range = arr.range(0, 0)

      assert(range, [])
    })

    it("returns an empty array if start is out of bounds", ->{
      let arr = [1, 2, 3]
      let range = arr.range(200, 5)

      assert(range, [])
    })

  })



}
