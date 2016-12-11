export = ->(it) {
  it("sets magic constants", ->(assert) {
    assert(__LINE__, 3)
    assert(__LINE__, 4)
    assert(__LINE__, 5)
    assert(__LINE__, 6)
    assert(__FILE__, "magic-constants.ch")

    let path = __DIR__
    path = path.split("/")

    assert(path.last(), "test")
  })
}
