export = func(it) {

  it("returns the length of a string", func(assert) {
    assert("hello world".length(), 11)
    assert("hello".length(), 5)
    assert("ääöü".length(), 4)
    assert("".length(), 0)
  })

  it("concatenates strings", func(assert) {
    assert("hello" + "world", "helloworld")
    assert("hello" + " wonderful " + "world", "hello wonderful world")
    assert("öö" + "üä", "ööüä")
    assert("" + "", "")
  })

  it("concatenates strings and numerics", func(assert) {
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

  it("multiplies strings", func(assert) {
    assert("test" * 3, "testtesttest")
    assert(" " * 3, "   ")
    assert("a" * 10, "aaaaaaaaaa")
    assert("a" * 1.5, "a")
    assert("a" * 1.999, "a")
  })

  it("trims whitespace off the beginning and end", func(assert) {
    assert("   hello  ".trim(), "hello")
    assert("         adad   ".trim(), "adad")
    assert("    asdadasd\n\nasdasd   ".trim(), "asdadasd\n\nasdasd")
    assert("äääüö\n\n\nlol".trim(), "äääüö\n\n\nlol")
  })

  it("inverts a string", func(assert) {
    assert("hello world".reverse(), "dlrow olleh")
    assert("test".reverse(), "tset")
    assert("reviver".reverse(), "reviver")
    assert("rotator".reverse(), "rotator")
    assert("          \ntest\t\t\n".reverse(), "\n\t\ttset\n          ")
  })

  it("filters a string", func(assert) {
    assert("hello beautiful world".filter(func(c) { c ! " " }), "hellobeautifulworld")
    assert("this-is-a-slug".filter(func(c) { c ! "-" }), "thisisaslug")
    assert("hello\nworld".filter(func(c) { c ! "\n" }), "helloworld")
  })

  it("returns each char in a string", func(assert) {
    let chars = []

    "charly".each(func(c) {
      chars.push(c)
    })

    assert(chars == ["c", "h", "a", "r", "l", "y"], true)
  })

  it("returns a char at a given index", func(assert) {
    assert(""[0], null)
    assert("test"[0], "t")
    assert("\ntest"[0], "\n")
  })

  it("returns a substring", func(assert) {
    assert("".substring(0, 5), "")
    assert("hello world".substring(0, 5), "hello")
    assert("hello".substring(0, 10), "hello")
    assert("hello world".substring(6, 5), "world")
    assert("what is going on here".substring(8, 5), "going")
    assert("".substring(10, 0), "")
  })

  it("maps over a string", func(assert) {
    let string = "lorem ipsum dolor sit amet"
    let mapped = string.map(func(c) {
      if (c == "e") {
        "$"
      } else if (c == "o") {
        "$"
      } else if (c == "i") {
        ""
      } else {
        c
      }
    })

    assert(mapped, "l$r$m psum d$l$r st am$t")
  })

  it("checks if a string is empty", func(assert) {
    assert("".empty(), true)
    assert("     ".empty(), false)
    assert("test".empty(), false)
    assert("ä".empty(), false)
    assert("\n".empty(), false)
  })

  it("splits a string into parts", func(assert) {
    assert("hello beautiful world".split(" ")[0], "hello")
    assert("we are seven".split("e")[1], " ar")
    assert("hello\nworld\n:D!".split("\n")[2], ":D!")
    assert("whatsup".split("") == ["w", "h", "a", "t", "s", "u", "p"], true)
  })

  it("returns the index of a substring", func(assert) {
    assert("hello beautiful world".index_of("hello", 0), 0)
    assert("hello beautiful world".index_of("beautiful", 0), 6)
    assert("hello beautiful world".index_of("world", 0), 16)
    assert("I'm not here".index_of("test", 0), -1)
    assert("hello beautiful world".index_of(" ", 0), 5)
  })

  it("lstrip", func(assert) {
    assert("hello world".lstrip(5), " world")
    assert("- myname".lstrip(2), "myname")
    assert("".lstrip(5), "")
    assert("what is going on".lstrip(999), "")
    assert("hello world".lstrip(0), "hello world")
    assert("hello world".lstrip(-5), "hello world")
  })

  it("rstrip", func(assert) {
    assert("hello world".rstrip(5), "hello ")
    assert("- myname".rstrip(2), "- myna")
    assert("".rstrip(5), "")
    assert("what is going on".rstrip(999), "")
    assert("hello world".rstrip(0), "hello world")
    assert("hello world".rstrip(-5), "hello world")
  })

  it("indents a string", func(assert) {
    let string = ""
    string += "okay"
    string += "\n"
    string += "what"
    string += "\n"
    string += "test"

    string = string.indent(2, "-")

    assert(string, "--okay\n--what\n--test")
  })

  it("checks if a string is a digit", func(assert) {
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
