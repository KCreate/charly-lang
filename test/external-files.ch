export = func(it) {

  it("requires a file", func(assert) {
    assert(require("./external.ch").num, 25)
    assert(require("./external.ch").num, 25)

    let external = require("./external.ch")
    external.num = 50

    assert(require("./external.ch").num, 50)

    # Reset for further tests
    external.num = 25
  })

  it("includes a file that's already required", func(assert) {
    let external = require("./external.ch")
    external.num = 50

    assert(require("./external.ch") == external, true)
    assert(require("./external.ch").num, 50)

    # Reset for further tests
    external.num = 25
  })

}
