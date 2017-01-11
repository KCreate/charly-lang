export = ->(describe, it, assert) {

  describe("writing", ->{

    it("adds properties to objects", ->{
      class Box {}
      let myBox = Box()
      myBox.name = "charly"
      myBox.age = 16

      assert(myBox.name, "charly")
      assert(myBox.age, 16)
    })

    it("adds functions to objects", ->{
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

    it("assigns via index expressions", ->{
      let Box = {
        let name = "test"
      }

      Box["name"] = "it works"

      assert(Box["name"], "it works")
    })

  })

  describe("scoping", ->{

    it("anonymous functions's self is sourced from the stack ", ->{
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

    it("assigns the correct scope to functions that are added from the outside", ->{
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

  })

  describe("redirecting operators", ->{

    it("redirects arithmetic operators", ->{
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

    it("redirects comparison operators", ->{
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

    it("redirects unary operators", ->{
      let myBox = {
        func __uplus() { "uplus" }
        func __uminus() { "uminus" }
        func __unot() { "unot" }
      }

      assert(+myBox, "uplus")
      assert(-myBox, "uminus")
      assert(!myBox, "unot")
    })

    it("redirects arithmetic operators with an operator as the func name", ->{
      let myBox = {
        func +(element) { "plus" }
        func -(element) { "minus" }
        func *(element) { "mult" }
        func /(element) { "divd" }
        func %(element) { "mod" }
        func **(element) { "pow" }
      }

      assert(myBox + 1, "plus")
      assert(myBox - 1, "minus")
      assert(myBox * 1, "mult")
      assert(myBox / 1, "divd")
      assert(myBox % 1, "mod")
      assert(myBox ** 1, "pow")
    })

    it("redirects comparison operators with an opereator as the func name", ->{
      let myBox = {
        func <(element) { "less" }
        func >(element) { "greater" }
        func <=(element) { "lessequal" }
        func >=(element) { "greaterequal" }
        func ==(element) { "equal" }
        func !(element) { "notequal" }
      }

      assert(myBox < 1, "less")
      assert(myBox > 1, "greater")
      assert(myBox <= 1, "lessequal")
      assert(myBox >= 1, "greaterequal")
      assert(myBox == 1, "equal")
      assert(myBox ! 1, "notequal")
    })

    it("redirects unary operators with an operator as the func name", ->{
      let myBox = {
        func +@() { "uplus" }
        func -@() { "uminus" }
        func !@() { "unot" }
      }

      assert(+myBox, "uplus")
      assert(-myBox, "uminus")
      assert(!myBox, "unot")
    })

  })

  describe("instanceof", ->{

    it("gives back null on container literals", ->{
      let Box = {}

      assert(Box.instanceof(), null)
    })

  })

  describe("pretty_printing", ->{

    it("displays objects as a string", ->{
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

  })

  describe("keys", ->{

    it("returns all keys of an object", ->{
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

    it("returns all keys of a class", ->{
      class Foo {
        static property lol

        static func bar() {
          "it works"
        }
      }

      let keys = Object.keys(Foo)
      assert(keys, ["lol", "bar", "name"])
    })

    it("returns all keys of a primitive class", ->{
      let keys = Object.keys(Array)
      assert(keys, [
        "pretty_print",
        "of_size",
        "name",
        "methods"
      ])
    })

    it("returns all keys of a function", ->{
      func foo() {}
      foo.some_data = [1, 2, 3]

      let keys = Object.keys(foo)
      assert(keys, ["name", "some_data"])
    })

    it("returns all keys of internal functions", ->{
      let method = __internal__method("_isolate_object")
      method.foo = 25

      let keys = Object.keys(method)
      assert(keys, ["name", "foo"])
    })

  })

  describe("tap", ->{

    it("passes the value to the callback", ->{
      let a = 25
      let check
      let c1 = ->check = $0
      a.tap(c1)
      assert(check, 25)
    })

  })

  describe("typeof", ->{

    it("returns the type() of a variable", ->{
      assert(false.typeof(), "Boolean")
      assert(true.typeof(), "Boolean")
      assert("test".typeof(), "String")
      assert(25.typeof(), "Numeric")
      assert(25.5.typeof(), "Numeric")
      assert([1, 2, 3].typeof(), "Array")
      assert((class Test {}).typeof(), "Class")
      assert((func() {}).typeof(), "Function")
      assert({}.typeof(), "Object")
      assert(null.typeof(), "Null")
    })

  })

  describe("to_n", ->{

    it("casts string to numeric", ->{
      assert("25".to_n(), 25)
      assert("25.5".to_n(), 25.5)
      assert("0".to_n(), 0)
      assert("100029".to_n(), 100029)
      assert("-89.2".to_n(), -89.2)

      assert("hello".to_n(), NAN)
      assert("25test".to_n(), 25)
      assert("ermokay30".to_n(), NAN)
      assert("-2.25this".to_n(), -2.25)

      assert("123.45e2".to_n(), 12345)
      assert("2e5".to_n(), 200_000)
      assert("25e-5".to_n(), 0.00025)
      assert("9e-2".to_n(), 0.09)
    })

  })

  describe("pipe", ->{

    it("pipes a value to different functions", ->{
      let res1
      let res2
      let res3

      func setRes1(v) {
        res1 = v
      }

      func setRes2(v) {
        res2 = v
      }

      func setRes3(v) {
        res3 = v
      }

      5.pipe(setRes1, setRes2, setRes3)

      assert(res1, 5)
      assert(res2, 5)
      assert(res3, 5)
    })

  })

  describe("transform", ->{

    it("transforms an array", ->{
      func reverse(array) {
        array.reverse()
      }

      func addOne(array) {
        array.map(func(e) { e + 1 })
      }

      func multiplyByTwo(array) {
        array.map(func(e) { e * 2 })
      }

      const nums = [1, 2, 3, 4, 5]
      const result = nums.transform(multiplyByTwo, reverse, addOne)
      assert(result, [11, 9, 7, 5, 3])
    })

  })

  describe("assign", ->{

    it("copies keys from one or more objects to another", ->{
      let Box1 = {
        let name = "box1"
      }

      let Box2 = {
        let age = 20
      }

      let Box3 = Object.assign({}, Box1, Box2)

      assert(Box3.name, "box1")
      assert(Box3.age, 20)
    })

  })

  describe("copy", ->{

    it("copies an object", ->{
      let test = {
        let name = "test"
        let foo = 25
      }

      let new_test = test.copy()
      test.name = "it changed"

      assert(new_test.name, "test")

      new_test.foo = 30

      assert(test.foo, 25)
    })

    it("doesn't copy sub-arrays", ->{
      let arr = [1, 2, 3]
      let obj = {
        let arr = arr
      }

      let copy = obj.copy()

      assert(copy.arr.length(), 3)

      arr.push(4)

      assert(copy.arr.length(), 4)
    })

    it("doesn't copy sub-objects", ->{
      let obj1 = { let prop = 1 }
      let obj2 = { let prop = obj1 }

      let copy = obj2.copy()

      obj1.prop = 25

      assert(copy.prop.prop, 25)

      obj2.prop = 200

      assert(copy.prop.typeof(), "Object")
    })

    describe("throws when trying to copy uncopiable values", ->{

      it("throws on functions", ->{
        try {
          Object.copy(func() {})
        } catch(e) {
          return assert(e.message, "Cannot copy functions")
        }

        assert(true, false)
      })

      it("throws on classes", ->{
        try {
          Object.copy(class Foo {})
        } catch(e) {
          return assert(e.message, "Cannot copy classes")
        }

        assert(true, false)
      })

      it("throws on primitive classes", ->{
        primitive class Foo {}

        try {
          Object.copy(Foo)
        } catch(e) {
          return assert(e.message, "Cannot copy primitive classes")
        }

        assert(true, false)
      })

    })

  })

  describe("deep_copy", ->{

    it("recursively copies an object", ->{
      let obj1 = { let prop = 2 }
      let obj2 = { let prop = obj1 }
      let obj3 = { let prop = obj2 }

      let copy = obj3.deep_copy()

      obj1.prop = 20

      assert(copy.prop.prop.prop, 2)

      obj3.prop = 200

      assert(copy.prop.typeof(), "Object")
    })

    it("copies sub-arrays", ->{
      let arr = [1, 2, 3]
      let obj = { let prop = arr }

      let copy = obj.deep_copy()

      arr.push(4)

      assert(copy.prop.length(), 3)
    })

    describe("throws when trying to copy uncopiable values", ->{

      it("throws on functions", ->{
        try {
          Object.deep_copy(func() {})
        } catch(e) {
          return assert(e.message, "Cannot deep_copy functions")
        }

        assert(true, false)
      })

      it("throws on classes", ->{
        try {
          Object.deep_copy(class Foo {})
        } catch(e) {
          return assert(e.message, "Cannot deep_copy classes")
        }

        assert(true, false)
      })

      it("throws on primitive classes", ->{
        primitive class Foo {}

        try {
          Object.deep_copy(Foo)
        } catch(e) {
          return assert(e.message, "Cannot deep_copy primitive classes")
        }

        assert(true, false)
      })

    })

  })

}
