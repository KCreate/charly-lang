const _trim = __internal__method("trim");
const _ord = __internal__method("ord");
const to_numeric = __internal__method("to_numeric");

export = primitive class String {

  # Trim whitespace
  func trim() {
    _trim(self)
  }

  # Returns an indented version of self
  func indent(amount, value) {
    @split("\n").map(->(line) {
      (value * amount) + line
    }).join("\n")
  }

  # Remove n characters from the left
  func lstrip(n) {
    @substring(n, @length() - n)
  }

  # Remove n characters from the right
  func rstrip(n) {
    @substring(0, @length() - n)
  }

  # Return this string reversed
  func reverse() {
    let new = ""
    @each(func(char) {
      new = char + new
    })
    new
  }

  # Return each char in this string
  func each(callback) {
    let i = 0
    let size = @length()
    while i < size {
      callback(self[i], i)
      i += 1
    }
    self
  }

  # Filter out unwanted characters from a string
  func filter(filter) {
    let new = ""
    @each(func(c) {
      if (filter(c)) {
        new += c
      }
    })
    new
  }

  # Return a substring from an index
  func substring(start, offset) {
    let index = start
    let end = start + offset
    let result = ""

    while (index < end) {
      if (self[index]) {
        result += self[index]
      }
      index += 1
    }

    result
  }

  # Returns a string that consists of the values returned by the callback
  func map(callback) {
    let new = ""
    @each(func(c) {
      new += callback(c)
    })
    new
  }

  # Returns true if the string is empty
  func empty() {
    @length() == 0
  }

  # Returns an array of numbers representing this char
  # If the char is a unicode char the array will contain 2 numbers and so on
  func ord() {
    _ord(self)
  }

  # Split this string into parts
  func split(needle) {
    let result = []
    let haystack = self
    let haystack_length = haystack.length()
    let needle_length = needle.length()

    let i = 0
    while (i < haystack_length) {
      if (haystack.substring(i, needle_length) == needle) {
        result.push(haystack.substring(0, i))
        haystack = haystack.substring(i + needle_length, haystack_length)
        haystack_length = haystack.length()
        i = 0
      }
      i += 1
    }

    # If the haystack still contains values append them too
    if (haystack.length() > 0) {
      result.push(haystack)
    }

    if haystack.length() == 0 {
      result.push("")
    }

    # If the needle was an empty string
    # remove the first element
    if (needle_length == 0) {
      result.delete(0)
    }

    result
  }

  # Return the index of needle inside self
  func index_of(needle, offset) {
    let found_index = -1
    let end_pos = @length() - needle.length()
    @each(func(char, i) {
      if (found_index == -1) {
        if ((i <= end_pos) && (i >= offset)) {
          if (@substring(i, needle.length()) == needle) {
            found_index = i
          }
        }
      }
    })
    found_index
  }

  # Return the numeric representation of this string
  func to_n() {
    to_numeric(self)
  }

  # Prompts self via gets and return the input
  func prompt() {
    io.stdin.gets(self, true)
  }

  func promptn() {
    io.stdin.gets(self, true).to_n()
  }

  func promptc() {
    io.stdin.getc()
  }

  func pretty_print() {
    ("\"" + self + "\"").colorize(32)
  }
}
