const array_insert = __internal__method("array_insert")
const array_delete = __internal__method("array_delete")
const array_of_size = __internal__method("array_of_size")
const _length = __internal__method("length")

export = primitive class Array {

  # Return a copy of this array
  func copy() {
    @map(func(e) { e })
  }

  # Calls the callback with each element and the index
  func each(callback) {
    let i = 0
    let size = _length(self)
    while i < size {
      callback(self[i], i, size)
      i += 1
    }
    self
  }

  # Calls the callback with each element and the index
  # The return value is an array of return values from the callback
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

  # Returns a new array whichs contains all
  # elements for which the passed block returned a truthy value
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

  # Returns true if this array is empty
  func empty() {
    _length(self) == 0
  }

  # Returns an array where all children are turned into strings
  func all_to_s() {
    @map(func(e) {
      e.to_s()
    })
  }

  # Append an item to the end of this array
  func push(item) {
    array_insert(self, item, _length(self))
    self
  }

  # Returns and removes the last element of the array
  func pop() {
    const item = @last()
    @delete(@length() - 1)
    item
  }

  # Append an item to the beginning of this array
  func unshift(item) {
    array_insert(self, item, 0)
    self
  }

  # Returns and removes the first element of the array
  func shift() {
    const item = @first()
    @delete(0)
    item
  }

  # Inserts *item* at *index*
  func insert(index, item) {
    array_insert(self, item, index)
    self
  }

  # Deletes the item at *index*
  func delete(index) {
    array_delete(self, index)
    self
  }

  # Returns the string representation of this array
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

  # Return a new array of a given size
  static func of_size(size, value) {
    array_of_size(size, value)
  }

  # Return the first element of this array
  func first() {
    self[0]
  }

  # Return the last element of this array
  func last() {
    self[_length(self) - 1]
  }

  # Return a reversed version of this array
  func reverse() {
    let new = []
    @each(func(e) {
      new.unshift(e)
    })
    new
  }

  # Returns a recursively flattened version of this array
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

  # Returns the index of *element* if found
  # Returns -1 of not found
  func index_of(element) {
    let index = -1
    let i = 0

    let length = @length()
    let found = false

    while (i < length) {
      if (!found) {
        if ((self[i].typeof() == element.typeof()) && (self[i] == element)) {
          index = i
          found = true
          i = length
        }
      }
      i += 1
    }

    index
  }

  # Join the elements of the array together
  func join(separator) {
    let string = ""
    let count = _length(self)

    @each(func(e, index) {
      string += e.to_s()

      # Unless were at the last element, append the separator
      if (index < count - 1) {
        string += separator.to_s()
      }
    })

    string
  }

  func range(start, end) {

    # Switch params if start is bigger
    if start > end {
      let tmp = end
      end = start
      start = tmp
    }

    # Create the new array
    const new = []
    const length = _length(self)
    start.upto(end, func(n) {
      if ((n >= -1) && n < length) {
        new.push(self[n])
      }
    })
    new
  }

  # Return a new array by concatening self and element
  # If element is an array, they will be merged
  func __plus(element) {
    if (element.typeof() ! "Array") {

      # Create a new array containing @length + 1 items
      let new_array = Array.of_size(@length() + 1, null)
      @each(func(v, i) {
        new_array[i] = v
      })
      new_array[new_array.length() - 1] = element
      new_array
    } else {

      # Create an array with the size of the two arrays combined
      let new_array = Array.of_size(@length() + element.length(), null)

      # Copy the values
      @each(func(v, i) {
        new_array[i] = v
      })

      element.each(func(v, i) {
        new_array[i + @length()] = v
      })

      new_array
    }
  }

  # Compare an array to something else
  func __equal(other) {

    if (other.typeof() == "Boolean") {
      return other
    }

    if (other.typeof() ! @typeof()) {
      return false
    }

    # Check the length
    if (other.length() ! @length()) {
      return false
    }

    # Iterate over the contents
    let equal = true
    other.each(func(e, i) {
      if (equal) {
        equal = e == self[i]
      }
    })
    equal
  }

  # Same as Array#__equal but negated
  func __not(other) {
    !@__equal(other)
  }

  # Sort an array
  func sort(sort_function) {
    let sorted = @copy()

    let left
    let right

    @length().times(func(i) {
      (@length() - 1).times(func(y) {

        left = sorted[i]
        right = sorted[y]

        if (sort_function(left, right)) {
          const tmp = left
          sorted[i] = right
          sorted[y] = left
        }

      })
    })

    sorted
  }
}
