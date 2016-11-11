require "../**"

module Charly::Internals

  # Returns the length of various types
  charly_api "length", value : BaseType do
    case value
    when TNumeric
      return value
    when TString
      return TNumeric.new(value.value.size.to_f64)
    when TArray
      return TNumeric.new(value.value.size.to_f64)
    else
      return TNumeric.new(0)
    end
  end
end
