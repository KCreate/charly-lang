export = ->(describe, it, assert) {

  it("receives an argument called ARGV", ->{
    assert(typeof ARGV, "Array")
    assert(ARGV.length(), 0)
  })

  it("receives an argument called IFLAGS", ->{
    assert(typeof IFLAGS, "Array")
    assert(IFLAGS.length(), 0)
  })

  it("receives an argument called ENV", ->{
    assert(typeof ENV, "Object")
    assert(typeof ENV.CHARLYDIR, "String")
  })

  it("has access to compile statistics", ->{
    const CHARLY = require("charly")

    assert(typeof CHARLY.VERSION, "String")
    assert(typeof CHARLY.LICENSE, "String")
    assert(typeof CHARLY.COMPILE_DATE, "String")

    assert(CHARLY.VERSION.length() > 0, true)
    assert(CHARLY.LICENSE.length() > 0, true)
    assert(CHARLY.COMPILE_DATE.length() > 0, true)

    assert(CHARLY.LICENSE.index_of("MIT", 0) ! -1, true)
  })

  it("maybe it has a commit sha", ->{
    const CHARLY = require("charly")

    if typeof CHARLY.COMPILE_COMMIT == "String" {
      assert(CHARLY.COMPILE_COMMIT.length(), 7)
    }
  })

}
