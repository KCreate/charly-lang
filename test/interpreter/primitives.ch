export = ->(describe, it, assert) {

  describe("self identifier", ->{

    it("inserts the self identifier", ->{
      Numeric.methods.cube = ->self ** 3
      assert(5.cube(), 125)
    })

    it("has access to the parent scope", ->{
      let count = 0
      Numeric.methods.bar = ->() {
        count += 1
      }

      1.bar()
      1.bar()
      1.bar()
      1.bar()
      1.bar()
      1.bar()
      1.bar()

      assert(count, 7)
    })

  })

  it("adds methods to primitive types", ->{
    Numeric.methods.add = ->(arg) {
      self + arg
    }

    assert(5.add(10), 15)
  })

  it("adds values to primitive types", ->{
    Numeric.methods.foo = 2

    assert(5.foo, 2)
  })

  it("extends a primitive type", ->{
    Array.methods.foo = ->"overridden"
    Boolean.methods.foo = ->"overridden"
    Class.methods.foo = ->"overridden"
    Function.methods.foo = ->"overridden"
    Null.methods.foo = ->"overridden"
    Numeric.methods.foo = ->"overridden"
    Object.methods.foo = ->"overridden"
    PrimitiveClass.methods.foo = ->"overridden"
    String.methods.foo = ->"overridden"

    assert([].foo(), "overridden")
    assert(false.foo(), "overridden")
    assert((class lol {}).foo(), "overridden")
    assert((func () {}).foo(), "overridden")
    assert(null.foo(), "overridden")
    assert(5.foo(), "overridden")
    assert({}.foo(), "overridden")
    assert((primitive class Foo {}).foo(), "overridden")
    assert("lol".foo(), "overridden")
  })

  it("gives primitive classes the name property", ->{
    assert(Array.name, "Array")
    assert(Boolean.name, "Boolean")
    assert(Class.name, "Class")
    assert(Function.name, "Function")
    assert(Null.name, "Null")
    assert(Numeric.name, "Numeric")
    assert(Object.name, "Object")
    assert(PrimitiveClass.name, "PrimitiveClass")
    assert(String.name, "String")
  })

  it("gives primitive classes the methods object", ->{
    assert(Array.methods.typeof(), "Object")
    assert(Boolean.methods.typeof(), "Object")
    assert(Class.methods.typeof(), "Object")
    assert(Function.methods.typeof(), "Object")
    assert(Null.methods.typeof(), "Object")
    assert(Numeric.methods.typeof(), "Object")
    assert(Object.methods.typeof(), "Object")
    assert(PrimitiveClass.methods.typeof(), "Object")
    assert(String.methods.typeof(), "Object")
  })

}
