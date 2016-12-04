export = func(it) {

  it("receives an argument called ARGV", func(assert) {
    assert(ARGV.typeof(), "Array")
    assert(ARGV.length(), 0)
  })

  it("receives an argument called IFLAGS", func(assert) {
    assert(IFLAGS.typeof(), "Array")
    assert(IFLAGS.length(), 0)
  })

  it("receives an argument called ENV", func(assert) {
    assert(ENV.typeof(), "Object")
    assert(ENV.CHARLYDIR.typeof(), "String")
  })

}
