export = ->(describe, it, assert) {

  it("returns the length of a string", ->{
    assert("hello world".length(), 11)
    assert("hello".length(), 5)
    assert("ääöü".length(), 4)
    assert("".length(), 0)
  })

  describe("concatenation", ->{

    it("concatenates strings", ->{
      assert("hello" + "world", "helloworld")
      assert("hello" + " wonderful " + "world", "hello wonderful world")
      assert("öö" + "üä", "ööüä")
      assert("" + "", "")
    })

    it("concatenates strings and numerics", ->{
      assert("test" + 16, "test16")
      assert("test" + 16.263723762, "test16.263723762")
      assert("test" + 0.001, "test0.001")
      assert("test" + 2.5, "test2.5")
      assert("test" + 2.0, "test2")

      assert(2 + "test", "2test")
      assert(2.5 + "test", "2.5test")
      assert(0.010 + "test", "0.01test")
      assert(28.2 + "test", "28.2test")
      assert(50 + "test" + 25, "50test25")
    })

  })

  describe("string multiplication", ->{

    it("number * string", ->{
      assert(5 * "test", "testtesttesttesttest")
      assert(1 * "test", "test")
      assert(0 * "test", "")
    })

    it("string * number", ->{
      assert("test" * 5, "testtesttesttesttest")
      assert("test" * 1, "test")
      assert("test" * 0, "")
    })

  })

  it("trims whitespace off the beginning and end", ->{
    assert("   hello  ".trim(), "hello")
    assert("         adad   ".trim(), "adad")
    assert("    asdadasd\n\nasdasd   ".trim(), "asdadasd\n\nasdasd")
    assert("äääüö\n\n\nlol".trim(), "äääüö\n\n\nlol")
    assert("test".trim(), "test")
  })

  it("reverses a string", ->{
    assert("hello world".reverse(), "dlrow olleh")
    assert("test".reverse(), "tset")
    assert("reviver".reverse(), "reviver")
    assert("rotator".reverse(), "rotator")
    assert("          \ntest\t\t\n".reverse(), "\n\t\ttset\n          ")
  })

  describe("filter", ->{

    it("filters out unwanted chars", ->{
      assert("hello beautiful world".filter(->(c) c ! " "), "hellobeautifulworld")
      assert("this-is-a-slug".filter(->(c) c ! "-"), "thisisaslug")
      assert("hello\nworld".filter(->(c) c ! "\n"), "helloworld")
    })

  })

  describe("each", ->{

    it("iterates over each char", ->{
      let message = "Charly"
      let chars = []

      message.each(->(char) chars.push(char))

      assert(chars, ["C", "h", "a", "r", "l", "y"])
    })

    it("returns the original string", ->{
      let message = "Charly"
      let got = message.each(->null)

      assert(got, "Charly")
    })

  })

  describe("map", ->{

    it("iterates over all chars", ->{
      let string = "Hello @"
      let name = "Bob"

      let greeting = string.map(->(char) {
        if char == "@" {
          name
        } else {
          char
        }
      })

      assert(greeting, "Hello Bob")
    })

    it("returns full chars and not bytes", ->{
      let string = "äöüÇ"
      let amount = 0

      string.map(->{
        amount += 1
      })

      assert(amount, 4)
    })

  })

  it("returns a char at a given index", ->{
    assert(""[0], null)
    assert("test"[0], "t")
    assert("\ntest"[0], "\n")
  })

  describe("substring", ->{

    it("doesn't add whitespace on index out of bounds", ->{
      let string = ""
      let sub = string.substring(0, 200)

      assert(sub, "")
    })

    it("returns a substring", ->{
      assert("".substring(0, 5), "")
      assert("hello world".substring(0, 5), "hello")
      assert("hello".substring(0, 10), "hello")
      assert("hello world".substring(6, 5), "world")
      assert("what is going on here".substring(8, 5), "going")
      assert("".substring(10, 0), "")
    })

  })

  it("checks if a string is empty", ->{
    assert("".empty(), true)
    assert("     ".empty(), false)
    assert("test".empty(), false)
    assert("ä".empty(), false)
    assert("\n".empty(), false)
  })

  describe("split", ->{

    it("splits a string into parts", ->{
      assert("hello beautiful world".split(" ")[0], "hello")
      assert("we are seven".split("e")[1], " ar")
      assert("hello\nworld\n:D!".split("\n")[2], ":D!")
      assert("whatsup".split("") == ["w", "h", "a", "t", "s", "u", "p"], true)
    })

  })

  it("returns the index of a substring", ->{
    assert("hello beautiful world".index_of("hello", 0), 0)
    assert("hello beautiful world".index_of("beautiful", 0), 6)
    assert("hello beautiful world".index_of("world", 0), 16)
    assert("I'm not here".index_of("test", 0), -1)
    assert("hello beautiful world".index_of(" ", 0), 5)
  })

  it("lstrip", ->{
    assert("hello world".lstrip(5), " world")
    assert("- myname".lstrip(2), "myname")
    assert("".lstrip(5), "")
    assert("what is going on".lstrip(999), "")
    assert("hello world".lstrip(0), "hello world")
    assert("hello world".lstrip(-5), "hello world")
  })

  it("rstrip", ->{
    assert("hello world".rstrip(5), "hello ")
    assert("- myname".rstrip(2), "- myna")
    assert("".rstrip(5), "")
    assert("what is going on".rstrip(999), "")
    assert("hello world".rstrip(0), "hello world")
    assert("hello world".rstrip(-5), "hello world")
  })

  it("indent", ->{
    let string = ""
    string += "okay"
    string += "\n"
    string += "what"
    string += "\n"
    string += "test"

    string = string.indent(2, "-")

    assert(string, "--okay\n--what\n--test")
  })

  it("checks if a string is a digit", ->{
    assert("".digit(), false)
    assert("hello".digit(), false)
    assert("-".digit(), false)
    assert(" ".digit(), false)
    assert("25".digit(), true)
    assert("2".digit(), true)
    assert("+".digit(), false)

    assert("0".digit(), true)
    assert("1".digit(), true)
    assert("2".digit(), true)
    assert("3".digit(), true)
    assert("4".digit(), true)
    assert("5".digit(), true)
    assert("6".digit(), true)
    assert("7".digit(), true)
    assert("8".digit(), true)
    assert("9".digit(), true)
  })

}
