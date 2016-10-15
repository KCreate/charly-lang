require "../types.cr"

class StackEntry
  include CharlyTypes
  property value : BaseType
  property locked : Bool

  def initialize(@value)
    @locked = false
  end
end
