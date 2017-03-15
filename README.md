[![Build Status](https://travis-ci.org/charly-lang/charly.svg?branch=master)](https://travis-ci.org/charly-lang/charly)
[![Version](https://img.shields.io/badge/Version-0.3.0-green.svg)](https://github.com/charly-lang/charly/releases/tag/v0.3.0)
[![License](https://img.shields.io/badge/License-MIT-blue.svg)](https://github.com/charly-lang/charly/blob/master/LICENSE)

<img align="right" alt="Charly" width="150" src="res/charly.png" />

# The Charly programming language

Charly is a dynamic, weakly-typed multi-paradigm programming language.
This repository contains a [Crystal](https://crystal-lang.org/) implementation of the language.

# Motivation and Goals

I've always been interested in the development and design of new programming languages.
This is my first try at writing an actual language. My primary goal was to learn how to teach
a machine what my language looks like and what it should do.
Based on the experiences I've made while working on Charly, I now feel comfortable
to experiment with lower-level technology such as virtual machines or compilers.

This implementation uses a tree-based execution model, which is (as opposed to a bytecode interpreter) rather
trivial to implement. Given that I never took any classes or read any books about this topic,
it was the easiest way for me to put up a working language. Charly might well switch to a bytecode-interpreter
in the future, but only once I've gathered enough experience to feel comfortable with writing a virtual-machine
for it.

> If you're interested in writing your own programming language, I've compiled a list of resources
you may find useful.

- [Compiler Design with Alex Aiken from Stanford](https://www.youtube.com/playlist?list=PLFB9EC7B8FE963EB8)
- [The Crystal Compiler](https://github.com/crystal-lang/crystal/tree/master/src/compiler)
- [Implementing Languages by Christopher Pitt](https://www.youtube.com/playlist?list=PLDjkcYOLgGdggfm9uVaopOueu1EheD4aN)
- [Writing a virtual machine by Terence Parr](https://www.youtube.com/watch?v=OjaAToVkoTw)

# Syntax and language guide

Visit the [website](https://charly-lang.github.io/charly) for an introduction to the language.

# Installation

1. Install [Crystal](https://crystal-lang.org)
2. Clone this repo with `git clone https://github.com/charly-lang/charly`
3. Run `install.sh`

You will be prompted for your admin password (used to copy to `/usr/local/bin`).

After that you need to set the `CHARLYDIR` environment variable. Just add the following line to your
`.bashrc`, `.zshrc`, etc. Replace the path with the path to the Charly source code (e.g The path to the git repo).

```bash
export CHARLYDIR=~/GitHub/charly-lang/charly
```

You can also build the interpreter via the following command:

```bash
$ mkdir bin
$ crystal build src/charly.cr --release -o bin/charly
```

This will place the executable in the `bin` folder.

# OS Support

I'm developing on macOS 10.12 so it should work without any problems on that.
The [CI Build](https://travis-ci.org/charly-lang/charly) runs on Ubuntu 12.04.5 LTS.

# CLI options

```
$ charly -v
Charly 0.3.0 [bb5b857] (15. March 2017)
$ charly -h
Usage: charly [filename] [flags] [arguments]
    -f FLAG, --flag FLAG             Set a flag
    -h, --help                       Print this help message
    -v, --version                    Prints the version number
    --license                        Prints the license

Flags:
    ast                              Display the AST of the userfile
    dotdump                          Dump dot language displaying the AST
    tokens                           Display tokens of the userfile
    lint                             Don't execute after parsing (linting)

53 internal methods are loaded
```

# Using the built-in REPL

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
```bash
$ charly repl these are all arguments
> ARGV
[these, are, all, arguments]
```

# [License](https://github.com/charly-lang/charly/blob/master/LICENSE)
