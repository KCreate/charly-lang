const _trim = __internal__method("trim");
const _ord = __internal__method("ord");
const to_numeric = __internal__method("to_numeric");

export = primitive class String {

  /*
   * Returns a new string where whitespace from the beginning and the end
   * of the string is returned
   * */
  func trim() {
    _trim(self)
  }

  /*
   * Returns a new string where each line is indented with (amount * value)
   *
   * ```
   * "hello".indent(2, "-") // => "--hello"
   * ```
   * */
  func indent(amount, value) {
    @split("\n").map(->(line) {
      (value * amount) + line
    }).join("\n")
  }

  /*
   * Returns a new string where the first *n* characters are removed
   * from the left side of the string
   * */
  func lstrip(n) {
    @substring(n, @length() - n)
  }

  /*
   * Returns a new string where the first *n* characters are removed
   * from the right side of the string
   * */
  func rstrip(n) {
    @substring(0, @length() - n)
  }

  /*
   * Returns this string but reversed
   * */
  func reverse() {
    let new = ""
    @each(func(char) {
      new = char + new
    })
    new
  }

  // Return each char in this string
  /*
   * Calls the callback with each char in this string
   *
   * ```
   * "hello".each(->(char) {
   *   print(char) // => will print each char on a new line
   * })
   * ```
   * */
  func each(callback) {
    let i = 0
    let size = @length()
    while i < size {
      callback(self[i], i)
      i += 1
    }
    self
  }

  /*
   * Returns a new string where each char for which the callback
   * returned false is removed
   *
   * ```
   * "hello world whats up".filter(->$0 ! " ") // => "helloworldwhatsup"
   * ```
   * */
  func filter(filter) {
    let new = ""
    @each(func(c) {
      if (filter(c)) {
        new += c
      }
    })
    new
  }

  /*
   * Returns a new string which is a substring
   * starting at *start* with a length of *offset*
   *
   * ```
   * "hello world".substring(5, 5) // => "world"
   * ```
   * */
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

  /*
   * Returns a new string where each char is replaced by the value
   * returned by the callback
   *
   * ```
   * "hello".map(->$0 + "-") // => "h-e-l-l-o-"
   * ```
   * */
  func map(callback) {
    let new = ""
    @each(func(c) {
      new += callback(c)
    })
    new
  }

  /*
   * Returns true if this string is empty (length is zero)
   *
   * ```
   * "".empty() // => true
   * " ".empty() // => false
   * "hello".empty() // => false
   * ```
   * */
  func empty() {
    @length() == 0
  }

  /*
   * Returns an array of numbers of the bytes of this char
   * If the char is a unicode character, the array will contain 2 or more numbers
   *
   * ```
   * "a".ord() // => [97]
   * "hello".ord() // => [104, 101, 108, 108, 111]
   * "ä".ord() // => [195, 164]
   * "".ord() // => []
   * ```
   * */
  func ord() {
    _ord(self)
  }

  /*
   * Returns an array of strings by splitting the original at every
   * occurence of the *needle*
   *
   * ```
   * "hello world whats up".split(" ") // => ["hello", "world", "whats", "up"]
   * "whats up".split("") // => ["h", "e", "l", "l", "o", " ", "w", "o", "r", "l", "d"]
   * ```
   * */
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

    // If the haystack still contains values append them too
    if (haystack.length() > 0) {
      result.push(haystack)
    }

    if haystack.length() == 0 {
      result.push("")
    }

    // If the needle was an empty string
    // remove the first element
    if (needle_length == 0) {
      result.delete(0)
    }

    result
  }

  /*
   * Returns the index of a substring
   *
   * ```
   * "hello world".index_of("world", 0) // => 6
   * "hello world".index_of("hello", 0) // => 0
   * "hello world".index_of(" ", 0) // => 5
   * ```
   * */
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

  /*
   * Tries to parse this string as a numeric value
   * Returns NAN if it failed
   * */
  func to_n() {
    to_numeric(self)
  }

  /*
   * Calls io.gets with self, appending to the readline history
   * */
  func prompt() {
    io.stdin.gets(self, true)
  }

  /*
   * Calls io.gets with self, appending to the readline history
   * After that it will try to convert the given value to a numeric
   * */
  func promptn() {
    io.stdin.gets(self, true).to_n()
  }

  /*
   * Prompts self and retrieves user input via io.stdin.getc
   * */
  func promptc() {
    io.stdout.write(self)
    io.stdin.getc()
  }

  /*
   * Pretty prints this string
   * */
  func pretty_print() {
    ("\"" + self + "\"").colorize(32)
  }
}
