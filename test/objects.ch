export = func(it) {

  it("can override native methods", func(assert) {
    let charly = {
      let name
      let age

      func to_s() {
        name + " is " + age + " years old!"
      }
    }
    charly.name = "charly"
    charly.age = 16

    let text = charly.to_s()
    assert(text, "charly is 16 years old!")
  })

  it("adds properties to objects", func(assert) {
    class Box {}
    let myBox = Box()
    myBox.name = "charly"
    myBox.age = 16

    assert(myBox.name, "charly")
    assert(myBox.age, 16)
  })

  it("adds functions to objects", func(assert) {
    class Box {}
    let myBox = Box()
    myBox.name = "charly"
    myBox.age = 16
    myBox.to_s = func() {
      assert(self == myBox, true)
      myBox.do_stuff = func() {
        "it works!"
      }

      myBox.name + " - " + myBox.age
    }

    assert(myBox.name, "charly")
    assert(myBox.age, 16)
    assert(myBox.do_stuff, null)
    assert(myBox.to_s(), "charly - 16")
    assert(myBox.do_stuff(), "it works!")
  })

  it("anonymous functions's self is sourced from the stack ", func(assert) {
    let val = 0

    let box1 = {
      let val = 1

      func callback(callback) {
        callback()
      }
    }

    let box2 = {
      let val = 2

      func call() {
        box1.callback(func() {
          @val = 200
        })
      }
    }

    box2.call()
    assert(val, 0)
    assert(box1.val, 1)
    assert(box2.val, 200)
  })

  it("redirects arithmetic operators", func(assert) {
    let myBox = {
      func __plus(element) { "plus" }
      func __minus(element) { "minus" }
      func __mult(element) { "mult" }
      func __divd(element) { "divd" }
      func __mod(element) { "mod" }
      func __pow(element) { "pow" }
    }

    assert(myBox + 1, "plus")
    assert(myBox - 1, "minus")
    assert(myBox * 1, "mult")
    assert(myBox / 1, "divd")
    assert(myBox % 1, "mod")
    assert(myBox ** 1, "pow")
  })

  it("redirects comparison operators", func(assert) {
    let myBox = {
      func __less(element) { "less" }
      func __greater(element) { "greater" }
      func __lessequal(element) { "lessequal" }
      func __greaterequal(element) { "greaterequal" }
      func __equal(element) { "equal" }
      func __not(element) { "notequal" }
    }

    assert(myBox < 1, "less")
    assert(myBox > 1, "greater")
    assert(myBox <= 1, "lessequal")
    assert(myBox >= 1, "greaterequal")
    assert(myBox == 1, "equal")
    assert(myBox ! 1, "notequal")
  })

  it("redirects unary operators", func(assert) {
    let myBox = {
      func __uminus() { "uminus" }
      func __unot() { "unot" }
    }

    assert(-myBox, "uminus")
    assert(!myBox, "unot")
  })

  it("assigns the correct scope to functions that are added from the outside", func(assert) {
    let Box = {
      let val = 0

      func do(callback) {
        callback(self)
      }
    }

    let val = 0

    Box.do(func(Box) {
      val = 30
      Box.val = 60
    })

    assert(val, 30)
    assert(Box.val, 60)

    Box.do2 = func() {
      val = 120
      @val = 90
    }
    Box.do2()

    assert(val, 120)
    assert(Box.val, 90)
  })

  it("assigns via index expressions", func(assert) {
    let Box = {
      let name = "test"
    }

    Box["name"] = "it works"

    assert(Box["name"], "it works")
  })

  it("gives back null on container literals", func(assert) {
    let Box = {}

    assert(Box.instanceof(), null)
  })

  it("displays objects as a string", func(assert) {
    let Box = {
      let name = "charly"
      let data = {
        let foo = "okay"
        let hello = "world"
      }
    }

    let render = Box.to_s()

    assert(render, "{\n  name: charly\n  data: {\n    foo: okay\n    hello: world\n  }\n}")
  })

  it("returns all keys of an object", func(assert) {
    let Box = {
      let name = "charly"
      let data = {
        let foo = "okay"
        let hello = "world"
      }
    }

    const keys = Object.keys(Box)
    assert(keys, ["name", "data"])
  })

}
