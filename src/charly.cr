require "./charly/syntax/parser.cr"
require "./charly/interpreter/interpreter.cr"

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
    # Parse the program
    program = Parser.create(File.open(filename), filename)

    # Run the program
    interpreter = Interpreter.new

    result = interpreter.exec_program program
    puts result
    puts interpreter.top
  rescue e : Exception
    puts e
  end
end
