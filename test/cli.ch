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

  it("has access to compile statistics", ->(assert) {
    const CHARLY = require("charly")

    assert(CHARLY.VERSION.typeof(), "String")
    assert(CHARLY.LICENSE.typeof(), "String")
    assert(CHARLY.COMPILE_DATE.typeof(), "String")

    assert(CHARLY.VERSION.length() > 0, true)
    assert(CHARLY.LICENSE.length() > 0, true)
    assert(CHARLY.COMPILE_DATE.length() > 0, true)

    assert(CHARLY.LICENSE.index_of("MIT", 0) ! -1, true)
  })

  it("maybe it has a commit sha", ->(assert) {
    const CHARLY = require("charly")

    if CHARLY.COMPILE_COMMIT.typeof() == "String" {
      assert(CHARLY.COMPILE_COMMIT.length(), 7)
    }
  })

}
