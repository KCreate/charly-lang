export = {
  let num = 25

  func foo() {
    "I am foo"
  }

  func bar(a, b) {
    a + b
  }
}

export.Person = class Person {
  property name
  property birthyear

  func constructor(name, birthyear) {
    @name = name
    @birthyear = birthyear
  }

  func greeting() {
    @name + " was born in " + @birthyear + "."
  }

}
