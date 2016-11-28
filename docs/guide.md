# Charly Language Guide
## Version 0.0.1

Your syntax files need to be encoded in UTF-8.

## Comments
Comments start with the sharp `#` character. Only one-line comments are currently supported.

```javascript
# This is a comment
```

## Literals

Charly has a total of 10 primitive types. Not all can be constructed directly. For example the `TInternalFunction` can only be gathered from a call to `__internal__method`

### Null
The `Null` type can be compared to `undefined` in javascript or `nil` in some other languages.

```javascript
null
```

### Boolean
A `Boolean` only has two different values: `true` and `false`.

```javascript
true
false
```

### Numeric
All Numeric types inside Charly are Crystal's native `Float64` type.

Numeric literals, just like any other expression in the language, can be prefixed with `-` to negate them.

Underscores can be used to make some numbers more readable:

```javascript
1_000_000 # better than 1000000
```

Floats are created using the `.` character.

```javascript
123_456.456_789
```

A Numeric will silently overflow if you pass the lower or upper limit of `Float64`. The following REPL session elaborates this:

![../images/overflow.png](Numeric literal overflowing)

Operations such as `1 / 0` will result in the `NAN` value.

### String
A String represents an immutable sequence of UTF-8 characters.

It uses Crystal's native `String` type underneath.

You can create it using `"` characters.

```javascript
"hello world"
```

A backslash can be used to denote various special characters inside the string:

```javascript
"\"" # double quote
"\\" # backslash
"\e" # escape
"\f" # form feed
"\n" # newline
"\r" # carriage return
"\t" # tab
"\v" # vertical tab
```

A string can span multiple lines:

```javascript
"hello
      word" # same as "hello\n     world"
```

### Array
An Array is a resizeable list of items of any type. It is typically created with an array literal:

```javascript
[1, 2, 3]
[1, "hello world", ["whats up"]]
```

You can add new items to an array using the push method:

```javascript
let nums = []
nums.push(0)
nums.push(1)
nums.push(2)

nums # [0, 1, 2]
```

You can concat two arrays together via the `+` operator:

```javascript
[1, 2] + [3, 4] # [1, 2, 3, 4]
```

You can compare two arrays using the regular `==` operator:

```javascript
[1, 2, 3, 4] == [1, 2, 3, 4] # true
[1, 2] == [3, 4] # false
```

### Objects

Charly doesn't have special syntax to create objects. Instead it uses something we call `Containers`.

A `Container` is basically the scope of a block turned into an Object:

```javascript
let Box = {
  let name = "charly"
  let age = 200
}

Box.name # "charly"
Box.age # 200
```

This can be compared to the javascript equivalent of using `new Function()`:

```javascript
let Box = (new function() {
  this.name = "charly"
  this.age = 200
})

Box.name // "charly"
Box.age // 200
```

You can access properties of objects via `[]`:

```javascript
let Box = {
  let name = "mybox"
}

Box["name"] # "mybox"
```

### Functions

You can define a new function like this:

```javascript
func foo() {
  return "hello world"
}
```

When written inside a block as a top-level-expression, it is automatically rewritten to the following:

```javascript
let foo = func() {
  return "hello world"
}
```

If you only need the function literal, you can use anonymous function literals:

```javascript
func foo(callback) {
  callback(42)
}

foo(func(arg) {
  print(arg) # 42
})
```

There is also the lambda syntax, which goes like this:

```javascript
[1, 2, 3].map(->(num) {
  print(num)
})

[1, 2, 3].map(->(num) print(num))
```

Of course you could also pass the print method directly, this would however result in the following:

```javascript
[1, 2, 3].map(print)

# 1
# 0
# 3
# 2
# 1
# 3
# 3
# 2
# 3
```

Because `Array#map` passes the value, index and size of the array to the callback, print will write all these values to the console.

When you write a lambda function without parenthesis or curly braces, it will wrap the expression inside a block.

The following:

```javascript
foo(->25)
```

becomes:

```javascript
foo(->{ 25 })
```

which in turn get's converted to:

```javascript
foo(func() {
  return 25
})
```

### Classes

Classes in Charly can inherit from multiple other classes.

They can have instance methods and properties and also static methods and properties.

Below is an example of a simple `Person` class.

```javascript
class Person {
  property name
  property age
  property height

  func constructor(name, age, height) {
    @name = name
    @age = age
    @height = height
  }

  func greet() {
    print("My name is " + @name)
    print("I am " + @age + " years old")
    print("I am " + @height + " cm tall")
  }
}

let John = Person("John", 21, 1.85)
John.greet()

# Will print
#
# My name is John
# I am 21 years old
# I am 1.85 cm tall
```

You define properties via the `property` keyword followed by an identifier.

To define a static method or property, prefix the property or func keyword with the `static` keyword.

```javascript
class Box {
  static property count

  static func foo() {
    "class method"
  }
}
Box.count = 0

Box.foo() # "class method"
```

To inherit from other classes, you use the `extends` keyword.

```javascript
class Foo {
  func foo() {
    "foo method"
  }
}

class Bar {
  func bar() {
    "bar method"
  }
}

class Baz extends Foo, Bar {
  func baz() {
    "baz method"
  }
}

let myBaz = Baz()
myBaz.foo() # "foo method"
myBaz.bar() # "bar method"
myBaz.baz() # "baz method"
```

Static properties and methods are also copied to the child classes. The values of static properties are copied by value. They are not references.

```javascript
class Foo {
  static property foo

  static func what() {
    "static what"
  }
}
Foo.foo = "test"

class Bar extends Foo {}

Bar.what() # "static what"
Bar.foo # "test"

Foo.foo = "hello world"

Bar.foo # "test"
```

## Assignments

Assignment is done with the `=` character.

```javascript
# assigns to a local variable
local = 1

# assigns to the current self variable
@instance = 2

# The above is simply rewritten to
self.instance = 2
```

## Control expressions

All control expressions inside charly behave as if they were regular expressions. You can't place them anywhere but they do return a value.

### if statements

The parenthesis around the test

```javascript

```
