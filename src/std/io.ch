const fs = require("fs")
const readline = __internal__method("readline")

export = {
  const STDIN  = fs(0, "/dev/stdin", "r", "utf8")
  const STDOUT = fs(1, "/dev/stdout", "r", "utf8")
  const STDERR = fs(2, "/dev/stderr", "r", "utf8")

  const print = {
    const stdout = func stdout() {
      arguments.each(->(arg) {
        STDOUT.puts(arg.to_s())
      })
    }

    const stderr = func stderr() {
      arguments.each(->(arg) {
        STDERR.puts(arg.to_s())
      })
    }
  }

  const write = {
    const stdout = func stdout() {
      arguments.each(->(arg) {
        STDOUT.print(arg.to_s())
      })
    }

    const stderr = func stderr() {
      arguments.each(->(arg) {
        STDERR.print(arg.to_s())
      })
    }
  }

  func gets(prompt) {
    const history = !!(arguments[1])
    readline(prompt, history)
  }

  func getc() {
    let char
    STDIN.raw(-> {
      char = STDIN.read_char()
    })
    char
  }

  const sleep = __internal__method("sleep")
  const exit = __internal__method("exit")
  const time_ms = __internal__method("time_ms")
  const eval = __internal__method("eval")
  const stacktrace = __internal__method("stacktrace")
}
