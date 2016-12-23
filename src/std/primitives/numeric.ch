export = primitive class Numeric {

  /*
   * Calls the callback *self* times, passing the current iteration count
   * as the first argument
   * */
  func times(callback) {
    let i = 0
    while (i < self) {
      callback(i)
      i += 1
    }

    self
  }

  /*
   * Calls the callback with each number from *self* down to *num*
   * self is inclusive, num isn't
   * */
  func downto(num, callback) {
    if (self > num) {
      let i = self
      while (i > num) {
        callback(i)
        i -= 1
      }
    }

    self
  }

  /*
   * Calls the callback with each number from *self* up to *num*
   * self is inclusive, num isn't
   * */
  func upto(num, callback) {
    if (self < num) {
      let i = self
      while (i < num) {
        callback(i)
        i += 1
      }
    }

    self
  }

  /*
   * Returns the absolute value of this number
   * */
  func abs() {
    if (self < 0) {
      -self
    } else {
      self
    }
  }

  /*
   * Returns the sign of this number
   * */
  func sign() {
    if self < 0 {
      -1
    } else if self > 0 {
      1
    } else {
      0
    }
  }

  /*
   * Returns the bigger one of self or *other*
   * */
  func max(other) {
    if (self < other) {
      other
    } else {
      self
    }
  }

  /*
   * Returns the smaller one of self or *other*
   * */
  func min(other) {
    if (self > other) {
      other
    } else {
      self
    }
  }

  /*
   * Returns true if self is close to *expect* considering a given *delta* value
   * */
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

  func days() {
    self * 1000 * 60 * 60 * 24
  }

  func weeks() {
    self * 1000 * 60 * 60 * 24 * 7
  }

  func to_n() {
    self
  }

  func pretty_print() {
    @to_s().colorize(33)
  }
}
