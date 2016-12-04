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

}
