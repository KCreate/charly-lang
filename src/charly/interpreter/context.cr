require "./trace.cr"

module Charly
  # `Context` includes data about the current program being executed
  private class Context
    property trace : Array(Trace)

    def initialize(@trace = [] of Trace)
    end
  end
end
