export = {
  func foo(callback) {
    callback()
  }

  func bar() {
    // This variable is undefined and will throw a RunTimeError
    undefined_variable
  }
}
