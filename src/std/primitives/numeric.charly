export = primitive class Numeric {
  # Call the callback n times
  # The callback receives the index
  func times(callback) {
    let i = 0
    while (i < self) {
      callback(i)
      i += 1
    }

    self
  }

  # Call the callback with values from n down to *num*
  #
  # 5.downto(2, func(i) {})
  # will receive: 5, 4, 3, 2
  func downto(num, callback) {
    if (self > num) {
      let i = self
      while (i ! num) {
        callback(i)
        i -= 1
      }
    }

    self
  }

  # Call the callback with values from n up to *num*
  #
  # 5.upto(10, func(i) {})
  # will receive: 5, 6, 7, 8, 9, 10
  func upto(num, callback) {
    if (self < num) {
      let i = self
      while (i ! num) {
        callback(i)
        i += 1
      }
    }

    self
  }

  # Returns the absolute value of this number
  func abs() {
    if (self < 0) {
      -self
    } else {
      self
    }
  }

  # Returns the biggest of two numbers
  func max(other) {
    if (self < other) {
      other
    } else {
      self
    }
  }

  # Returns the smaller of two numbers
  func min(other) {
    if (self > other) {
      other
    } else {
      self
    }
  }

  # Returns true if self is in delta range of expect
  func close_to(expect, delta) {
    (self - expect).abs() <= delta
  }

  func miliseconds() {
    self
  }

  func seconds() {
    self * 1000
  }

  func minutes() {
    self * 1000 * 60
  }

  func hours() {
    self * 1000 * 60 * 60
  }

  func to_n() {
    self
  }
}
