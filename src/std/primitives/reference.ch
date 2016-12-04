export = primitive class Reference {
  func to_s() {
    "Reference:" + @value().typeof()
  }

  func value() {
    &self
  }
}
