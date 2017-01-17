module Charly
  # `Context` includes data about the current program being executed
  private class Context
    property trace : Array(Trace)

    def initialize(@trace)
    end
  end
end
