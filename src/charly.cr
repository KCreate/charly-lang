require "./charly/syntax/parser.cr"

module Charly

  unless ARGV.size > 0
    puts "Missing filename"
    exit 1
  end

  start = Time.now

  begin
    myParser = Parser.new(File.open(ARGV[0]), "debug")
    program = myParser.parse
  rescue e : SyntaxError
    puts e
  end
end
