require "readline"
require "../**"

module Charly::Internals
  charly_api "stdout_print", variadic: true do
    arguments.each do |arg|
      STDOUT.puts arg
      STDOUT.flush
    end
    return TNull.new
  end

  charly_api "stdout_write", variadic: true do
    arguments.each do |arg|
      STDOUT.print arg
      STDOUT.flush
    end
    return TNull.new
  end

  charly_api "stderr_print", variadic: true do
    arguments.each do |arg|
      STDERR.puts arg
      STDERR.flush
    end
    return TNull.new
  end

  charly_api "stderr_write", variadic: true do
    arguments.each do |arg|
      STDERR.print arg
      STDERR.flush
    end
    return TNull.new
  end

  # Reads a single char from STDIN (without the need of pressing return)
  charly_api "stdin_getc" do
    char = STDIN.raw &.read_char
    return TString.new("#{char}")
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
    return TString.new("#{scope}")
  end

  # Returns the current timestamp in miliseconds
  charly_api "time_ms" do
    return TNumeric.new(Time.now.epoch_ms.to_f64)
  end

  # Sleep for *amount* miliseconds
  charly_api "sleep", amount : TNumeric do
    sleep amount.value / 1000
    return TNull.new
  end

  #  Evaluate a string
  charly_api "eval", source : TString, context : TObject do
    # Parse the program
    # We have to append a whitespace because wtf
    # This is most likely an issue with the IO::Memory type not being able to pass the end border
    program = Parser.create("#{source.value} ", "--virtual--file--")

    prelude = visitor.prelude
    visitor = Visitor.new context.data, prelude

    backup_parent = context.data.parent
    context.data.parent = prelude
    result = visitor.visit_program(program, context.data)
    context.data.parent = backup_parent
    return result
  end

  charly_api "file_get_contents", path : TString do
    if File.exists?(path.value) && File.readable?(path.value)
      return TString.new(File.read(path.value))
    end

    return TNull.new
  end
end
