export = ->(it) {
  it("sets magic constants", ->(assert) {
    assert(__LINE__, 3)
    assert(__FILE__, "magic-constants.ch")

    let path = __DIR__
    path = path.split("/")

    assert(path.last(), "test")
  })
}
