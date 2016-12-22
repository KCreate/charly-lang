export = ->(it) {

  it("lexes javascript style comments", ->(assert) {
    // Test
    assert(true, true)
  })

  it("lexes javascript style multiline comments", ->(assert) {
    /*
     * Hello World
     * */

    assert(true, true)
  })

}
