const array_insert = __internal__method("array_insert")
const array_delete = __internal__method("array_delete")
const array_of_size = __internal__method("array_of_size")
const _length = __internal__method("length")

export = primitive class Array {

  /*
   * Return a copy of this array
   * */
  func copy() {
    @map(func(e) { e })
  }

  /*
   * Calls the callback with each value inside this array
   * The index is passed as the second argument
   * The size of the array is passed as the third argument
   *
   * This is non-mutating
   * */
  func each(callback) {
    let i = 0
    let size = _length(self)
    while i < size {
      callback(self[i], i, size)
      i += 1
    }
    self
  }

  /*
   * Calls the callback with each value inside this array
   * The index is passed as the second argument
   * The size of the array is passed as the third argument
   *
   * This returns a new array filled with the values returned by the callback
   * */
  func map(callback) {
    let i = 0
    let size = _length(self)
    let new = []
    while i < size {
      new.push(callback(self[i], i, size))
      i += 1
    }
    new
  }

  /*
   * Returns a new array which contains all the values
   * for which the callback returned a truthy value
   * */
  func filter(callback) {
    let new = []
    let i = 0
    let size = _length(self)
    let result
    while i < size {
      result = callback(self[i], i, size)
      if result {
        new.push(self[i])
      }
      i += 1
    }
    new
  }

  /*
   * Returns true if this array is empty (length is 0)
   * */
  func empty() {
    _length(self) == 0
  }

  /*
   * Returns a new array where all the values are turned into strings
   * */
  func all_to_s() {
    @map(func(e) {
      e.to_s()
    })
  }

  /*
   * Appends an item to the end of this array
   *
   * This is mutating
   * */
  func push(item) {
    array_insert(self, item, _length(self))
    self
  }

  /*
   * Removes and returns the last value of this array
   *
   * This is mutating
   * */
  func pop() {
    const item = @last()
    @delete(@length() - 1)
    item
  }

  /*
   * Prepends an item to the beginning of this array
   *
   * This is mutating
   * */
  func unshift(item) {
    array_insert(self, item, 0)
    self
  }

  /*
   * Removes and returns the first value of this array
   *
   * This is mutating
   * */
  func shift() {
    const item = @first()
    @delete(0)
    item
  }

  /*
   * Inserts *item* at *index* inside this array
   *
   * If the index is smaller than 0, this behaves the same as unshift
   * If the index is bigger than the size of the array, this behaves the same as push
   * */
  func insert(index, item) {
    array_insert(self, item, index)
    self
  }

  /*
   * Removes the element at *index*
   *
   * If the index is smaller than 0, the first element is removed
   * If the index is bigger than the size of the array, the last element is removed
   * */
  func delete(index) {
    array_delete(self, index)
    self
  }

  /*
   * Renders this array as a string
   * */
  func to_s() {
    let io = "["
    let amount = _length(self)
    @each(func(e, i) {
      io += e.to_s()

      if i ! amount - 1 {
        io += ", "
      }
    })
    io += "]"
    io
  }

  func pretty_print() {
    let io = "["
    let amount = _length(self)
    @each(func(e, i) {
      io += e.pretty_print()

      if i ! amount - 1 {
        io += ", "
      }
    })
    io += "]"
    io
  }

  /*
   * Returns a new array of size *size* filled with *value*
   * */
  static func of_size(size, value) {
    array_of_size(size, value)
  }

  /*
   * Returns the first element of this array
   * */
  func first() {
    self[0]
  }

  /*
   * Returns the last element of this array
   * */
  func last() {
    self[_length(self) - 1]
  }

  /*
   * Creates a copy of this array with all elements in reverse order
   * */
  func reverse() {
    let new = []
    @each(func(e) {
      new.unshift(e)
    })
    new
  }

  /*
   * Creates a new array by recursively flattening this array
   * */
  func flatten() {
    let new = []

    @each(func(e) {
      if (e.typeof() == "Array") {
        e.flatten().each(func(e) {
          new.push(e)
        })
      } else {
        new.push(e)
      }
    })

    new
  }

  /*
   * Returns the index of the first item that is equal to *element* and has the same type
   * */
  func index_of(element) {
    let index = -1
    let i = 0

    let length = @length()
    let found = false

    while (i < length) {
      const self_val = self[i]
      if self_val.typeof() == element.typeof() && self_val == element {
        index = i
        found = true
        i = length
        break
      }
      i += 1
    }

    index
  }

  /*
   * Returns a string by concatenating each value
   * */
  func join(separator) {
    let string = ""
    let count = _length(self)

    @each(func(e, index) {
      string += e.to_s()

      // Unless were at the last element, append the separator
      if (index < count - 1) {
        string += separator.to_s()
      }
    })

    string
  }

  /*
   * Returns a new array, containing *amount* elements from the *start*
   * */
  func range(start, amount) {
    const items = []
    const size = @length()

    if start >= size { return [] }
    if amount == 0 { return [] }
    if size == 0 { return [] }

    start.upto(start + amount, ->(index) {
      if index < size {
        items.push(self[index])
      }
    })
    items
  }

  /*
   * Returns a new array by concatenating self and the other array
   * If the argument is not an array, it will be appended (non-mutating)
   * */
  func +(element) {
    if (element.typeof() ! "Array") {

      // Create a new array containing @length + 1 items
      let new_array = Array.of_size(@length() + 1, null)
      @each(func(v, i) {
        new_array[i] = v
      })
      new_array[new_array.length() - 1] = element
      new_array
    } else {

      // Create an array with the size of the two arrays combined
      let new_array = Array.of_size(@length() + element.length(), null)

      // Copy the values
      @each(func(v, i) {
        new_array[i] = v
      })

      element.each(func(v, i) {
        new_array[i + @length()] = v
      })

      new_array
    }
  }

  /*
   * Returns true if this array is equal to another array or value
   * */
  func ==(other) {

    const other_type = other.typeof()

    if (other_type == "Boolean") {
      return other
    }

    if (other_type ! @typeof()) {
      return false
    }

    // Check the length
    if (other.length() ! @length()) {
      return false
    }

    // Iterate over the contents
    let equal = true
    other.each(func(e, i) {
      if (equal) {
        equal = e == self[i]
      }
    })
    equal
  }

  /*
   * Same as == but negated
   * */
  func !(other) {
    !@__equal(other)
  }

  /*
   * Returns a sorted copy of this array
   * The callback receives two values to compare.
   * A truthy value means the the left side is bigger than the right side
   *
   * This uses the bubble-sort algorithm
   * */
  func sort(sort_function) {
    const sorted = @copy()

    let left
    let right

    @length().times(->(i) {
      (@length() - 1).times(->(y) {

        left = sorted[i]
        right = sorted[y]

        if (sort_function(left, right)) {
          sorted[i] = right
          sorted[y] = left
        }

      })
    })

    sorted
  }
}
