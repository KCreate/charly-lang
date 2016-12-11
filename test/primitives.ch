export = ->(it) {
  it("extends a primitive type", func(assert) {
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

  it("can overwrite static methods", func(assert) {
    let backup_size_of = Array.size_of
    Array.size_of = ->"hello world"
    assert(Array.size_of(), "hello world")
    Array.size_of = backup_size_of
  })

  it("gives primitive classes the methods object", func(assert) {
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

  it("can give references as a variable", func(assert) {
    let num = 25

    Numeric.methods.bar = &num

    assert(5.bar.value(), 25)
    assert(5.bar.typeof(), "Reference")
  })
}
