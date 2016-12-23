[![Build Status](https://travis-ci.com/KCreate/charly-lang.svg?token=yitMwy9Lg5peiAqCZjoK&branch=master)](https://travis-ci.com/KCreate/charly-lang)
[![Version](https://img.shields.io/badge/Version-0.0.1-green.svg)](https://github.com/KCreate/charly-lang/releases/tag/v0.0.1)
[![License](https://img.shields.io/badge/License-MIT-blue.svg)](https://github.com/KCreate/charly-lang/blob/master/LICENSE)

<img align="right" alt="Charly" width="150" src="docs/images/charly.png" />

# The Charly programming language

This is my try at writing an interpreter of a dynamic language from scratch with my bare hands. It is implemented in [Crystal](https://crystal-lang.org/). It is absolutely not production-ready and is meant only for my own learning-purposes.

# Syntax and language guide

Take a look at the [official website](https://kcreate.github.io/charly-lang/) for an introduction to the language.

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

```javascript
> ARGV
[these, are, all, arguments]
```

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
Usage: charly [filename] [flags] [arguments]
    -f FLAG, --flag FLAG             Set a flag
    -h, --help                       Print this help message
    -v, --version                    Prints the version number

Flags:
    ast                              Display the AST of the userfile
    tokens                           Display tokens of the userfile
    lint                             Don't execute after parsing (linting)
```

# Atom Syntax Theme

Thanks to [@SpargelPlays](https://github.com/SpargelPlays) for modifying the [language-javascript](https://atom.io/packages/language-javascript) package to make it work with Charly.

Github: [language-charly](https://github.com/SpargelPlays/language-charly)

Atom.io: [language-charly](https://atom.io/packages/language-charly)

# Contributors

[Contributors](https://github.com/KCreate/charly-lang/blob/master/CONTRIBUTORS.md)

# Inspired by
- Javascript
- Ruby

[License](https://github.com/KCreate/charly-lang/blob/master/LICENSE)
