require "./charly/syntax/parser.cr"

module Charly

  unless ARGV.size > 0
    puts "Missing filename"
    exit 1
  end
  filename = ARGV[0]

  start = Time.now

  begin
    myParser = Parser.new(File.open(filename), filename)
    program = myParser.parse
    puts program.tree
    puts program.path
    puts program.source
  rescue e : SyntaxError
    puts e
  end
end
