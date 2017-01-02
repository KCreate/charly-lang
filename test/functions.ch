export = func(it) {

  it("calls a function", func(assert) {
    let called = false
    func call_me() {
      called = true
    }
    call_me()

    assert(called, true)
  })

  it("passes arguments to a function", func(assert) {
    let arg1
    let arg2
    func call_me(_arg1, _arg2) {
      arg1 = _arg1
      arg2 = _arg2
    }
    call_me("hello", 25)

    assert(arg1, "hello")
    assert(arg2, 25)
  })

  it("creates the __argument variable", func(assert) {
    let args_received
    func call_me() {
      args_received = arguments
    }
    call_me("hello", "world", "this", "should", "work")

    assert(args_received == ["hello", "world", "this", "should", "work"], true)
  })

  it("can access the parent scope", func(assert) {
    let change_me = false
    func call_me() {
      change_me = true
    }
    call_me()

    assert(change_me, true)
  })

  it("writes to arguments instead of parent scope", func(assert) {
    let dont_change_me = false
    func call_me(dont_change_me) {
      dont_change_me = true
    }
    call_me(true)

    assert(dont_change_me, false)
  })

  it("runs callbacks in the right scope", func(assert) {
    let change_me = false

    func call_me(callback) {
      let change_me = 25
      callback()
    }

    call_me(func() {
      change_me = true
    })

    assert(change_me, true)
  })

  it("consecutive call expressions", func(assert) {
    func call_me() {
      func() {
        func() {
          25
        }
      }
    }

    assert(call_me()()(), 25)
  })

  it("passes arguments in the right order", func(assert) {
    let f1
    let f2
    let f3

    func(a1) {
      func(a2) {
        func(a3) {
          f1 = a1
          f2 = a2
          f3 = a3
        }
      }
    }(1)(2)(3)

    assert(f1, 1)
    assert(f2, 2)
    assert(f3, 3)
  })

  it("gives functions the correct self pointer", func(assert) {
    let box = {
      let val = "in box"

      func foo() {
        got = @val
      }
    }

    let got = null
    box.foo()

    assert(got, "in box")
  })

  it("gives direct function calls the correct self pointer", func(assert) {
    let box = {
      let val = "in box"

      func foo() {
        func bar() {
          got = @val
        }

        bar()
      }
    }

    let got = null
    box.foo()

    assert(got, "in box")
  })

  it("callbacks receive the correct self pointer", func(assert) {
    func foo(callback) {
      callback()
    }

    let box = {
      let val = "in box"

      func bar() {
        foo(func() {
          got = @val
        })
      }
    }

    let got = null
    box.bar()

    assert(got, "in box")
  })

  it("assigned functions receive the correct self pointer", func(assert) {
    let box = {
      let val = "in box"
    }

    box.foo = func() {
      got = @val
    }

    let got = null
    box.foo()

    assert(got, "in box")
  })

  it("functions in nested objects get the correct self pointer", func(assert) {
    let box = {
      let val = "upper box"

      let foo = {
        let val = "inner box"

        func bar() {
          got = @val
        }
      }
    }

    let got = null
    box.foo.bar()

    assert(got, "inner box")
  })

  it("assigned functions in nested objects get the correct self pointer", func(assert) {
    let box = {
      let val = "upper box"

      let foo = {
        let val = "inner box"
      }
    }

    let got = null

    box.foo.bar = func bar() {
      got = @val
    }

    box.foo.bar()

    assert(got, "inner box")
  })

  it("does explicit returns with an argument", func(assert) {
    func foo() {
      return 25
    }

    assert(foo(), 25)
  })

  it("does explicit returns without argument", func(assert) {
    func foo() {
      return 25
    }

    assert(foo(), 25)
  })

  it("does explicit returns from an object", func(assert) {
    let Box = {
      func foo() {
        return 25
      }
    }

    assert(Box.foo(), 25)
  })

  it("does explicit returns from nested ifs", func(assert) {
    func foo(arg) {
      if arg <= 10 {
        return false
      }

      return true
    }

    assert(foo(0), false)
    assert(foo(5), false)
    assert(foo(10), false)

    assert(foo(15), true)
    assert(foo(20), true)
    assert(foo(25), true)
  })

  it("runs lambda functions", func(assert) {
    let nums = [1, 2, 3, 4]
    nums = nums.map(->(num) num ** 2)

    assert(nums, [1, 4, 9, 16])
  })

  it("assigns lambda functions to variables", func(assert) {
    let myFunc = ->(arg, arg2) {
      arg + arg2
    }

    const result = myFunc(25, 100)

    assert(result, 125)
  })

  it("gives lambda functions the correct self pointer", func(assert) {
    let Box = {
      const name = "charly"
    }
    Box.foo = ->@name

    assert(Box.foo(), "charly")
  })

  it("correctly parses nested lambda functions", func(assert) {
    const myFunc = ->->{
      25
    }

    assert(myFunc().typeof(), "Function")
    assert(myFunc()(), 25)
  })

  it("sets props on function literals", func(assert) {
    func foo() {}
    func bar(a, b, c) {}
    const a = func() {}

    assert(foo.name, "foo")
    assert(bar.name, "bar")
    assert(a.name, "")
  })

  it("inserts quick access identifiers for regular methods calls", func(assert) {
    func foo() {
      $0 + $1 + $2
    }

    let result = foo(1, 2, 3)
    assert(result, 6)
  })

  it("inserts quick access identifiers for method calls on objects", func(assert) {
    let Box = {
      func foo() {
        $0 + $1 + $2
      }
    }

    let result = Box.foo(1, 2, 3)
    assert(result, 6)
  })

  it("inserts quick access identifiers for method calls on arrays", func(assert) {
    let methods = [
      func foo() {
        $0 + $1 + $2
      }
    ]

    let result = methods[0](1, 2, 3)
    assert(result, 6)
  })

  it("inserts quick access identifiers on redirected properties", func(assert) {
    Numeric.methods.foo = func() {
      $0 + $1 + $2
    }

    let result = 5.foo(1, 2, 3)
    assert(result, 6)
  })

  it("inserts quick access identifiers into lambda functions", func(assert) {
    let numbers = [1, 2, 3, 4]

    let result = numbers.map(->$0 * 2)
    assert(result, [2, 4, 6, 8])
  })

  it("can overwrite quick access identifiers", func(assert) {
    func foo($2, $1, $0) {
      [$0, $1, $2]
    }

    let result = foo(1, 2, 3)
    assert(result, [3, 2, 1])
  })

  it("throws when disallowed names are used as a argument name", func(assert) {
    func foo(self, __internal__method) {
      print(self, __internal__method)
    }

    try {
      foo(25)
    } catch(e) {
      assert(true, true)
      return
    }

    assert(false, true)
  })

  it("doesn't save methods without a name", func(assert) {
    let box = {
      func() {}
    }

    assert(box[""].typeof(), "Null")
  })

}
