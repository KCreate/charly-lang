# Interpreter
require "./stack/stack.cr"
require "./interpreter.cr"
require "./session.cr"

# Parsing
require "../syntax/parser/parser.cr"

class InterpreterFascade
  property top : Stack
  property session : Session?
  property flags : Array(String)

  def initialize(session = nil, flags = [] of String)
    @session = session
    @top = Stack.new nil
    @flags = flags
  end

  def execute_file(file, stack = @top)

    # Parsing
    parser = Parser.new file, @flags
    parser.parse
    program = parser.tree

    # Setup the stack
    stack.file = file
    stack.session = @session

    # Execute the file in the interpreter
    unless @flags.includes? "noexec"
      Interpreter.new [program], stack, @flags
    else
      CharlyTypes::TNull.new
    end
  end
end
