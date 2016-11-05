require "../program.cr"

module Charly

  # `Context` includes data about the current program being executed
  private class Context
    property program : Program

    def initialize(@program)
    end
  end
end
