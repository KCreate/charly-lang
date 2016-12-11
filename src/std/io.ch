const stdout_print = __internal__method("stdout_print")
const stdout_write = __internal__method("stdout_write")
const stderr_print = __internal__method("stderr_print")
const stderr_write = __internal__method("stderr_write")

export = {

  # Raw bindings to the output methods
  const raw = {
    const stdout = {
      const print = stdout_print
      const write = stdout_write
    }

    const stderr = {
      const print = stderr_print
      const write = stderr_write
    }
  }

  # Various bindings to STDOUT
  const stdout = {
    func print() {
      arguments.each(func(arg) {
        stdout_print(arg.to_s())
      })
      null
    }

    func write() {
      arguments.each(func(arg) {
        stdout_write(arg.to_s())
      })
      null
    }
  }

  # Various bindings to STDERR
  const stderr = {
    func print() {
      arguments.each(func(arg) {
        stderr_print(arg.to_s())
      })
      null
    }

    func write() {
      arguments.each(func(arg) {
        stderr_write(arg.to_s())
      })
      null
    }
  }

  # Various bindings to STDIN
  const stdin = {
    const gets = __internal__method("stdin_gets")
    const getc = __internal__method("stdin_getc")
  }

  # Sleep for some miliseconds
  const sleep = __internal__method("sleep")

  # Immediately exit the program
  const exit = __internal__method("exit")

  # Returns the current scope visualized as a table
  const stackdump = __internal__method("stackdump")

  # Get the current timestamp in miliseconds
  const time_ms = __internal__method("time_ms");

  # Eval
  const eval = __internal__method("eval");
}
