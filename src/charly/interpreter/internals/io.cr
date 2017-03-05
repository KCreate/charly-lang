require "readline"
require "../**"

module Charly::Internals
  charly_api "stdout_print" do
    arguments.each do |arg|
      STDOUT.puts arg
      STDOUT.flush
    end
    return TNull.new
  end

  charly_api "stdout_write" do
    arguments.each do |arg|
      STDOUT.print arg
      STDOUT.flush
    end
    return TNull.new
  end

  charly_api "stderr_print" do
    arguments.each do |arg|
      STDERR.puts arg
      STDERR.flush
    end
    return TNull.new
  end

  charly_api "stderr_write" do
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

  # Returns the current timestamp in miliseconds
  charly_api "time_ms" do
    return TNumeric.new(Time.now.epoch_ms)
  end

  # Sleep for *amount* miliseconds
  charly_api "sleep", amount : TNumeric do
    sleep amount.value / 1000
    return TNull.new
  end

  #  Evaluate a string
  charly_api "eval", source : TString, environment : TObject do

    # Parse the program
    # A newline is appended to make sure we don't
    # have any conflicts in the lexer
    program = Parser.create("#{source.value}\n", "--virtual--file--")

    # Switch the parent to the prelude
    b_parent = environment.data.parent
    environment.data.parent = visitor.prelude

    result = visitor.visit_program(program, environment.data, context)

    # Restore old parent
    environment.data.parent = b_parent

    return result
  end

  charly_api "file_get_contents", path : TString do
    if File.exists?(path.value) && File.readable?(path.value)
      return TString.new(File.read(path.value))
    end

    return TNull.new
  end

  # Returns the current stacktrace
  charly_api "stacktrace" do
    trace = context.trace
    entries = TArray.new

    trace.each do |entry|
      entries.value << TString.new "#{entry}"
    end

    return entries
  end
end
