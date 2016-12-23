export = primitive class Reference {

  /*
   * Display this reference as a string
   * */
  func to_s() {
    "Reference:" + @value().typeof()
  }

  /*
   * Dereferences this reference
   * */
  func value() {
    &self
  }
}
