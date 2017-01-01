export = func(it) {

  it("creates a new class", func(assert) {
    class Person {
      property name
      property age

      func constructor(name, age) {
        @name = name
        @age = age
      }
    }

    let charly = Person("charly", 16)
    let peter = Person("Peter", 20)

    assert(charly.name, "charly")
    assert(charly.age, 16)
    assert(peter.name, "Peter")
    assert(peter.age, 20)
  })

  it("calls functions inside classes", func(assert) {
    class Box {
      property value
      func set(value) {
        @value = value
      }
    }

    let myBox = Box()
    assert(myBox.value, null)
    myBox.set("this works")
    assert(myBox.value, "this works")
  })

  it("doesn't read from the parent stack", func(assert) {
    class Box {}
    let myBox = Box()

    let changed = false
    assert(myBox.changed, null)
  })

  it("doesn't write into the parent stack", func(assert) {
    class Box {}
    let myBox = Box()

    let changed = false
    myBox.changed = true

    assert(changed, false)
  })

  it("calls methods from parent classes", func(assert) {
    class Box {
      func foo() {
        "it works"
      }
    }

    class SpecialBox extends Box {}

    const myBox = SpecialBox()
    assert(myBox.foo(), "it works")
  })

  it("calls methods from parent classes inside child methods", func(assert) {
    class Box {
      func foo() {
        "it works"
      }
    }

    class SpecialBox extends Box {
      func bar() {
        @foo()
      }
    }

    const myBox = SpecialBox()
    assert(myBox.bar(), "it works")
  })

  it("sets props on classes", func(assert) {
    class A {
      property name
      property age

      func constructor(name, age) {
        @name = name
        @age = age
      }

      func foo() {}
      func bar() {}
    }

    assert(A.name, "A")
  })

  it("sets props on child classes", func(assert) {
    class A {
      property name

      func bar() {}
    }

    class B extends A {
      property age

      func constructor(name, age) {
        @name = name
        @age = age
      }

      func foo() {}
    }

    assert(B.name, "B")
  })

  it("gives back the class of an object", func(assert) {
    class Box {}

    const mybox = Box()

    assert(mybox.instanceof(), Box)
  })

  it("creates static properties on classes", func(assert) {
    class Box {
      static property count

      func constructor() {
        Box.count += 1
      }
    }
    Box.count = 0

    Box()
    Box()
    Box()
    Box()

    assert(Box.count, 4)
  })

  it("creates static methods on classes", func(assert) {
    class Box {
      static func do_something() {
        "static do_something"
      }

      func do_something() {
        "instance do_something"
      }
    }

    const myBox = Box()
    assert(myBox.do_something(), "instance do_something")
    assert(Box.do_something(), "static do_something")
  })

  it("inherits static methods to child classes", func(assert) {
    class Box {
      static func foo() {
        "static foo"
      }
    }

    class SubBox extends Box {}

    assert(SubBox.foo(), "static foo")
  })

  it("inherits static properties to child classes", func(assert) {
    class Box {
      static property foo
    }
    Box.foo = 0

    class SubBox extends Box {}

    assert(SubBox.foo, 0)

    Box.foo += 100

    assert(Box.foo, 100)
    assert(SubBox.foo, 0)
  })

  it("passes the class via the self identifier on static methods", func(assert) {
    class Box {
      static func foo() {
        assert(self, Box)
      }
    }

    Box.foo()
  })

  it("inserts quick access identifiers into constructor calls", func(assert) {
    class Box {
      property value

      func constructor() {
        @value = $0 + $1 + $2
      }
    }

    let box = Box(1, 2, 3)
    assert(box.value, 6)
  })

  it("set the __class property", func(assert) {
    class Box {}
    const myBox = Box()

    assert(myBox.__class, Box)
  })

  it("can't overwrite the __class property", func(assert) {
    class Box {
      property __class

      func constructor() {
        @__class = 25
      }
    }

    const myBox = Box()
    assert(myBox.__class == 25, false)
    assert(myBox.__class == Box, true)
  })

  it("inherits properties from parent classes", func(assert) {
    class Foo {
      property a
    }

    class Bar {
      property b
    }

    class Baz {
      property c
    }

    class Qux extends Foo, Bar, Baz {}

    let myqux = Qux()
    assert(Object.keys(myqux), ["a", "b", "c", "__class"])
  })

  it("inherits methods from parent classes", func(assert) {
    class Foo {
      func a() { "method a" }
    }

    class Bar {
      func b() { "method b" }
    }

    class Baz extends Foo, Bar {}

    let mybaz = Baz()
    assert(mybaz.a(), "method a")
    assert(mybaz.b(), "method b")
  })

  it("doesn't leak class properties into higher scopes", func(assert) {
    let a = 25

    class Box {
      property a
    }

    Box()

    assert(a, 25)
  })

  it("self reference in constructors doesn't leak into parent scope", func(assert) {
    let a = 25

    class Box {
      property a

      func constructor() {
        @a = 50
      }
    }

    let myBox = Box()

    assert(myBox.a, 50)
    assert(a, 25)
  })

  it("doesn't leak method declarations into higher scopes", func(assert) {
    let a = 25

    class Box {
      func a() {}
    }

    Box()

    assert(a.typeof(), "Numeric")
    assert(a, 25)
  })

  it("doesn't leak static properties into higher scopes", func(assert) {
    let a = 25

    class Box {
      static property a
    }

    assert(a.typeof(), "Numeric")
    assert(a, 25)
  })

  it("doesn't leak static methods into higher scopes", func(assert) {
    let a = 25

    class Box {
      static func a() {}
    }

    assert(a.typeof(), "Numeric")
    assert(a, 25)
  })
}
