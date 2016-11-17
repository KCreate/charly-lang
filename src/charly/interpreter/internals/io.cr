require "readline"
require "../**"

module Charly::Internals

  charly_api "stdout_print", variadic: true do
    arguments.each do |arg|
      STDOUT.puts arg.to_s
      STDOUT.flush
    end
    return TNull.new
  end

  charly_api "stdout_write", variadic: true do
    arguments.each do |arg|
      STDOUT.print arg.to_s
      STDOUT.flush
    end
    return TNull.new
  end

  charly_api "stderr_print", variadic: true do
    arguments.each do |arg|
      STDERR.puts arg.to_s
      STDERR.flush
    end
    return TNull.new
  end

  charly_api "stderr_write", variadic: true do
    arguments.each do |arg|
      STDERR.print arg.to_s
      STDERR.flush
    end
    return TNull.new
  end

  # Reads a single char from STDIN (without the need of pressing return)
  charly_api "stdin_getc" do
    char = STDIN.raw &.read_char
    return TString.new(char.to_s)
  end

  # Read a string (return terminated) from STDIN
  # Prepends *prepend* to the input and adds to the history if *history* is passed
  charly_api "stdin_gets", prepend : TString, history : TBoolean do
    return TString.new(Readline.readline(prepend.value, history.value) || "")
  end

  # Exit the program
  # *code* is used as the exit code
  charly_api "exit", code : TNumeric do
    exit(code.value.to_i)
    return TNull.new
  end

  # Returns the current scope rendered as a string
  charly_api "stackdump" do
    return TString.new(scope.to_s)
  end

  # Returns the current timestamp in miliseconds
  charly_api "time_ms" do
    return TNumeric.new(Time.now.epoch_ms.to_f64)
  end

  # Sleep for *amount* seconds
  charly_api "sleep", amount : TNumeric do
    sleep amount.value / 1000
    return TNull.new
  end

  # Evaluate a string
  charly_api "eval", source : TString, context : TObject do

    # Parse the program
    program = Parser.create(source.value, "--virtual--file--")

    puts program.tree

    prelude = interpreter.prelude
    interpreter = Interpreter.new context.data, prelude
    return interpreter.exec_program(program, context.data)
  end
end
