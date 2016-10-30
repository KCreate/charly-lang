require "./charly/syntax/parser.cr"

module Charly

  unless ARGV.size > 0
    puts "Missing filename"
    exit 1
  end

  start = Time.now
  myParser = Parser.new(File.open(ARGV[0]), "debug")
  program = myParser.parse_program

  puts "Done: #{Time.now - start}"
end
