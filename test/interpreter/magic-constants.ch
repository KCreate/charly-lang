export = ->(describe, it, assert) {

  it("sets magic constants", ->{
    assert(__LINE__, 4)
    assert(__LINE__, 5)
    assert(__LINE__, 6)
    assert(__LINE__, 7)
    assert(__FILE__, "magic-constants.ch")

    let path = __DIR__
    path = path.split("/")

    assert(path.last(), "interpreter")
  })

}
