require "./charly/syntax/parser.cr"

module Charly

  myParser = Parser.new(File.open("./examples/todolist.charly"), "./examples/todolist.charly")
  loop do
    if myParser.read_token.type == TokenType::EOF
      break
    end
  end

  myParser.token_dump
end
