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
    prelude = Parser.create(File.open(PRELUDE_PATH), PRELUDE_PATH)
    interpreter.exec_program prelude, prelude_scope

    # Parse and run the user file
    program = Parser.create(File.open(filename), filename)
    interpreter.exec_program program, user_scope
  rescue e : UserException
    puts e
    exit 1
  rescue e : Exception
    puts e
    exit 1
  end
end
