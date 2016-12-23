const math = __internal__method("math");

export = {
  const PI = 3.14159265358979323846
  const E = 2.7182818284590451
  const LOG2 = 0.69314718055994529
  const LOG10 = 2.3025850929940459

  func cos(value) { math("cos", value) }
  func cosh(value) { math("cosh", value) }
  func acos(value) { math("acos", value) }
  func acosh(value) { math("acosh", value) }

  func sin(value) { math("sin", value) }
  func sinh(value) { math("sinh", value) }
  func asin(value) { math("asin", value) }
  func asinh(value) { math("asinh", value) }

  func tan(value) { math("tan", value) }
  func tanh(value) { math("tanh", value) }
  func atan(value) { math("atan", value) }
  func atanh(value) { math("atanh", value) }

  func cbrt(value) { math("cbrt", value) }
  func sqrt(value) { math("sqrt", value) }

  func ceil(value) { math("ceil", value) }
  func floor(value) { math("floor", value) }

  func log(value) { math("log", value) }

  func rand() { math("rand", 0) }
}
