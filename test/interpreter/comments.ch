export = ->(describe, it, assert) {

  it("lexes # comments", ->{
    # Test
    assert(true, true)
  })

  it("lexes double slash comments", ->{
    // Test
    assert(true, true)
  })

  it("lexes multiline comments", ->{
    /*
     * Hello World
     * */
    assert(true, true)
  })

}
