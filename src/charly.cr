require "./charly/syntax/parser.cr"
require "./charly/interpreter/interpreter.cr"
require "./charly/gc_warning.cr"

module Charly

  # Check for the filename
  unless ARGV.size > 0
    puts "Missing filename"
    exit 1
  end
  filename = ARGV[0]

  # Check if $CHARLYDIR is set
  unless ENV.has_key? "CHARLYDIR"
    puts "$CHARLYDIR is not configured!"
    exit 1
  end

  begin

    prelude_scope = Scope.new
    user_scope = Scope.new(prelude_scope)
    interpreter = Interpreter.new(user_scope, prelude_scope)

    # Parse and run the prelude
    start = Time.now.epoch_ms
    prelude = Parser.create(File.open(PRELUDE_PATH), PRELUDE_PATH)
    puts "Prelude parse took: #{Time.now.epoch_ms - start}"

    start = Time.now.epoch_ms
    interpreter.exec_program prelude, prelude_scope
    puts "Prelude exec took: #{Time.now.epoch_ms - start}"

    # Parse and run the user file
    start = Time.now.epoch_ms
    program = Parser.create(File.open(filename), filename)
    puts "Userfile parse took: #{Time.now.epoch_ms - start}"

    start = Time.now.epoch_ms
    interpreter.exec_program program, user_scope
    puts "Userfile exec: #{Time.now.epoch_ms - start}"
  rescue e : UserException
    puts e
    exit 1
  rescue e : Exception
    puts e
    exit 1
  end
end
