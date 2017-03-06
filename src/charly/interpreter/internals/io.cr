require "readline"
require "../**"

module Charly::Internals

  # Read a string (return terminated) from STDIN
  # Prepends *prepend* to the input and adds to the history if *history* is passed
  charly_api "readline", prepend : TString, history : TBoolean do
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
