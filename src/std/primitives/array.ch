const array_insert = __internal__method("array_insert")
const array_delete = __internal__method("array_delete")
const array_of_size = __internal__method("array_of_size")
const _length = __internal__method("length")

// Collection of sorting algorithms
const Sort = require("../sort.ch")

const PrettyPrintHistory = []

export = primitive class Array {

  /*
   * Return a copy of this array
   * */
  func copy() {
    @map(->(e) e)
  }

  /*
   * Returns a recursive copy of this array
   * (sub-arrays and objects are copied)
   * */
  func deep_copy() {
    @map(->(e) e.deep_copy())
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
   * Passes a function to the callback which returns the next item
   * The callback is called as long as there are values inside self
   * */
  func iterate(callback) {
    let i = 0

    func read() {
      self[i].tap(->{ i += 1  })
    }

    while i < @length() {
      callback(read)
    }

    self
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

    PrettyPrintHistory.push(Object.object_id(self))

    @each(func(e, i) {
      if PrettyPrintHistory.includes(Object.object_id(e)) {
        io += "(circular)"
      } else {
        io += e.to_s()
      }

      if i ! amount - 1 {
        io += ", "
      }
    })
    io += "]"

    PrettyPrintHistory.pop()

    io
  }

  static func pretty_print(value) {

    unless typeof value == "Array" {
      throw Exception("Expected argument to be an array, got " + typeof value)
    }

    PrettyPrintHistory.push(Object.object_id(value))

    let io = "["
    let amount = value.length()
    value.each(func(e, i) {

      if PrettyPrintHistory.includes(Object.object_id(e)) {
        io += "(circular)"
      } else {
        io += Object.pretty_print(e)
      }

      if i ! amount - 1 {
        io += ", "
      }
    })
    io += "]"

    PrettyPrintHistory.pop()

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
      if (typeof e == "Array") {
        e.flatten().each(func(e) {
          new.push(e)
        })
      } else {
        new.push(e)
      }
    })

    new
  }

  /**
   * Returns the index of the first element that is equal to *element*
   * Searching low to high indices
   **/
  func index(element, offset) {
    const length = @length()
    if offset < 0 { offset += length }
    if offset < 0 { return -1 }

    const element_id = Object.object_id(element)
    const element_type = typeof element

    let index = -1

    while (offset < length) {
      const val = self[offset]

      if element_id == Object.object_id(val) {
        index = offset
        break
      }

      if typeof val == element_type && val == element {
        index = offset
        break
      }

      offset += 1
    }

    index
  }

  /**
   * Returns the index of the first element that is equal to *element*
   * Searching high to low indices
   **/
  func rindex(element, offset) {
    const length = @length()
    if offset < 0 { offset += length }
    if offset >= length { return -1 }

    const element_id = Object.object_id(element)
    const element_type = typeof element

    let index = -1

    while (offset >= 0) {
      const val = self[offset]

      if element_id == Object.object_id(val) {
        index = offset
        break
      }

      if typeof val == element_type && val == element {
        index = offset
        break
      }

      offset -= 1
    }

    index
  }

  /*
   * Returns true if value is inside this array
   * This is an alias for Array#index_of(foo) ! -1
   * */
  func includes(value) {
    @index(value, 0) ! -1
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

    // Return a copy of the current array and append the item
    if (typeof element ! "Array") {
      let new = @copy()
      new.push(element)
      return new
    }

    // Create a copy and append each item of the other array
    let new = @copy()
    element.each(->(item) {
      new.push(item)
    })
    return new
  }

  /*
   * Returns true if this array is equal to another array or value
   * */
  func ==(other) {

    const other_type = typeof other

    if (other_type ! typeof self) {
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
   *
   * If the array contains less than 20 elements
   * the Bubblesort algorithm is chosen, if there
   * are more Quicksort is used.
   * */
  func sort() {
    const array = @copy()

    if array.length() < 20 {
      Sort.Bubblesort(array)
    } else {
      Sort.Quicksort(array)
    }

    return array
  }
}
