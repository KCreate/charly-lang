require "../program.cr"

module Charly

  # `Context` includes data about the current program being executed
  private class Context
    property program : Program
    property trace : Array(Trace)

    def initialize(@program, @trace)
    end
  end
end
