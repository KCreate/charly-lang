[![Build Status](https://travis-ci.com/KCreate/charly-lang.svg?token=yitMwy9Lg5peiAqCZjoK&branch=master)](https://travis-ci.com/KCreate/charly-lang)
[![Version](https://img.shields.io/badge/Version-0.0.1-green.svg)](https://github.com/KCreate/charly-lang/releases/tag/v0.0.1)
[![License](https://img.shields.io/badge/License-MIT-blue.svg)](https://github.com/KCreate/charly-lang/blob/master/LICENSE)
[![Maintenacne](https://img.shields.io/maintenance/yes/2016.svg)](https://github.com/KCreate/charly-lang)

<img align="right" alt="Charly" width="150" src="docs/images/charly.png" />

# The Charly programming language

This is my try at writing an interpreter of a dynamic language from scratch with my bare hands. It is implemented in [Crystal](https://crystal-lang.org/). It is absolutely not production-ready and is meant only for learning-purposes.

# Syntax

__Declaring a variable__
```charly
let number = 900
let float = 5.5928
let string = "Hello World"
let boolean = true
let array = [1, "charly", false]
let nullvalue = null
let nanvalue = NAN
let object = {
  let name = "leonard"
  let age = 16
}
```

__Declaring constants__
```charly
const PI = 3.14159265358979323846
const E = 2.7182818284590451

PI = 4 # Cannot redeclare constant PI
```

__Objects__
```charly
let Box = {
  let name = "mybox"
}

Box.name # mybox
Box["name"] # mybox
Box.name = "yourbox"
Box.name # yourbox
Box["name"] # yourbox

Box.age # null
Box["age"] = 16
Box.age # 16
```

__Declaring a function__
```charly
func callback(value, callback) {
  callback(value)
}

let result = callback(25, func(value) {
  value * 2
})

result # => 50
```

__Times & While loops__
```charly
5.times(func(i) {
  print("Hello")
})

let i = 0
while i < 10 {
  print("In a while loop")
  i += 1
}
```

__User Input__
```charly
# Strings
let input = "> ".prompt()
print(input)

# Numbers
let input_number = "> ".promptn()
print(input_number)
```

__Primitive types__
```charly
25.typeof()                           # => Numeric
25.5.typeof()                         # => Numeric
"Charly".typeof()                     # => String
[1, 2, 3].typeof()                    # => Array
null.typeof()                         # => Null
NAN.typeof()                          # => Numeric
false.typeof()                        # => Boolean
(class Box {}).typeof()               # => Class
(func() {}).typeof()                  # => Function
{ let name = "charly" }.typeof()      # => Object
```

__Including other files__
```charly
# Include a file in the current directory
require("foo.charly")
require("./foo.charly")
require("./dir/foo.charly")

# Include the math module from the standard library
require("math")
```

__Working with arrays__
```charly
let array = [1, 2, 3]
array.push(4)
print(array) # => [1, 2, 3, 4]
print(array[1]) # => 2
```

__Classes & Objects__
```charly
class Person {
  let name
  let age

  func constructor(name, age) {
    self.name = name
    self.age = age
  }
}

let leonard = Person("Leonard", 16)
print(leonard.name) # "Leonard"
print(leonard.age) # 16
```

# Semicolons & Parens

Even though semicolons are completely optional, you should use them. For example the following two examples would be evaluated the same way:

```charly
2 test lol 2 * 2 test ()
```

```charly
2;
test;
lol;
2 * 2;
test();
```

You can use semicolons after If and while statements:

```charly
if (true) {
  # code
};

while (true) {
  # code
};
```

The parens around If and while statements are also optional:

```charly
if size < 100 {
  # code
}

while should_exit {
  # code
}
```

__CLI arguments and flags__

You can access flags passed to the interpreter via the global `IFLAGS` array. Flags are stored as a String.
Command line arguments (arguments passed after the filename which are not flags) are available via `ARGV`.

Current environment variables are available via the object `ENV`.

Example:
```
$ charly test.charly 1 2 3 -f ast
```

Will result in:

```charly
ARGV          # [1, 2, 3]
IFLAGS        # [ast]
ENV["SHELL"]  # /bin/bash
ENV.SHELL     # /bin/bash
```

# Using the built-in REPL

You can use the arrow keys to navigate the cursor. Up and down will scroll through the history.

```
$ charly repl
> 2 + 2
4
> "test"
test
> $ * 4
testtesttesttest
> func increment(a) { a + 1 }
Function
> increment(25)
26
> print("hello world")
hello world
null
> .exit
```

If you need to pass arguments or flags to a REPL session you can do so via the repl command
```
charly repl these are all arguments
```

```charly
> ARGV
[these, are, all, arguments]
```

# Everything is an object
When you write `5`, the interpreter actually treats it as a primitive. There are no funny castings or object instantiations. You can normally write code like `2 + 5` and it will work. Once you do something like `5.times(func() {})`, the interpreter searches the function for the given type. If it finds the method, it injects a variable called `self` into the function's stack and executes it.

This allows the interpreter to reuse the same object for all primitives.

This principle applies to all language primitives. The `Array` object for example, specifies a method called `push` which inserts an element into the array.

# Stack layers
Every file, function, class, object etc. gets it's own stack layer. A stack layer is in essence just a Hashmap that has a pointer to it's parent layer. When you write `myname`, the interpreter searches the current layer for a entry for this variable. If it's not found, it searches the parent layer. If a value is not found in this structure, an exception is raised stating `myname` is not defined.

When you execute a file, let's say *foo.charly*, the layer structure looks like this:
```
-------------   
| Top Layer |  Contains values like ARGV, IFLAGS and ENV
-------------
      ^
      |
--------------------  Contains bindings to stdout, stderr, stdin
| Standard Prelude |  and various other functions
--------------------  
        ^   ^
        |   |
        |   |   -------------- Contains the functions that are callable on primitive types
        |   \---| Primitives | See the upper paragraph *Everything is an object*
        |       -------------- for a better explanation of what this is
        |
--------------------------
| User file (foo.charly) | Contains all values declared within your program
--------------------------
```

Let's assume the content of *foo.charly* is the following
```charly
func foo(arg) {
  let myval = arg + 1
}

let value = 25
foo(value)
```

The layer structure now looks like this:
```
--------------------------
| User file (foo.charly) |
|                        |
| value: 25              |
| foo: Function          |
--------------------------
            ^
            |
            |
    -----------------
    | Function: foo |
    |               |
    | arg: 25       |
    | myval: 26     |
    -----------------
```

# Behaviour of *self* in methods
The self keyword always points to the object a method was called on. Where the method currently lives is not taken into consideration. Example:
```charly
let value = 10

let Box = {
  let value = 10

  func foo(new) {
    self.value = new
  }
}

# Both the outer value and the value inside Box are set to 10

Box.foo(20)
# Outer *value* is still 10, Box.value is now 20

let foo = Box.foo
foo(50)
# Outer *value* is still 10, Box.value is now 50
```

If you directly call method, the interpreter will set *self* to whatever value it was in the scope where the function was defined in. That's the reason why Box.value was set to 50. It behaves kind of like [Arrow functions in JavaScript](https://developer.mozilla.org/en/docs/Web/JavaScript/Reference/Functions/Arrow_functions). This means you can _"extract"_ functions and they keep working the way you expect them to.

Example:
```charly
let Box = {
  let name = "leonard"

  func greet() {
    "Hello " + self.name
  }
}

let greet = Box.greet
print(greet()) # will print Hello leonard
```

This currently only works on objects. If you try to extract a method like *each* from an Array this won't work. It will just result in undefined behaviour.

# Syntax errors
When the interpreter finds a syntax error, it will be nicely presented to you via the following format:

```
SyntaxError in debug.charly
Unexpected token: Identifier
40.
41. const buffer = files[i].content
42. const size = buffer.length()
43. const offset = size - position
44.
45. if (offset < 25 thisfails) {
    ~~~~~~~~~~~~~~~~^
```

The offending piece will be highlighted red. If your terminal doesn't support colors, an arrow also points to the offensive part.

# OS Support
I'm developing on macOS 10.12 so it should work without any problems on that.
The [CI Build](https://travis-ci.com/KCreate/charly-lang) runs on Ubuntu 12.04.5 LTS.

# Installation
You will need a working [crystal](http://crystal-lang.org/) installation.

To install the `charly` command and automatically copy it to the `/usr/bin` folder, run `install.sh`.
You will be prompted for your admin password (used to copy to `/usr/bin`).

# CLI options
```
$ charly -h
Usage: charly filename [options] [arguments]
    -f FLAG, --flag FLAG             Set a flag
    -h, --help                       Print this help message
    -v, --version                    Print the version number

Flags:
    ast                              Display the AST of the userfile
    tokens                           Display tokens of the userfile
    noexec                           Disable execution
    stackdump                        Dump the userfile stack at the end of execution
```

# Contributors
- [KCreate - Leonard Schütz](https://github.com/KCreate)

# Inspired by
- Javascript
- C
- Ruby

[License](https://github.com/KCreate/charly-lang/blob/master/LICENSE)
