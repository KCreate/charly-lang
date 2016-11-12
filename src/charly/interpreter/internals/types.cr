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

  # Return the name of the type as a string
  charly_api "typeof", value : BaseType do
    return TString.new("#{value.class}")
  end

  # Convert a string to a numeric
  charly_api "to_numeric", value : TString do
    num = value.value.gsub("_", "").to_f64(strict: false)

    if num.is_a? Float64
      return TNumeric.new(num)
    else
      return TNumeric.new(Float64::NAN)
    end
  end
end
