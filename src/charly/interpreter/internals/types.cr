require "../**"

module Charly::Internals
  # Returns the length of various types
  charly_api "length", value : BaseType do
    case value
    when .is_a? TNumeric
      return value
    when .is_a? TString
      return TNumeric.new(value.value.size.to_f64)
    when .is_a? TArray
      return TNumeric.new(value.value.size.to_f64)
    else
      return TNumeric.new(0)
    end
  end

  charly_api "_object_id", value : BaseType do
    return TNumeric.new value.object_id
  end
end
