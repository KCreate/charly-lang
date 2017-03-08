require "../**"

module Charly::Internals
  # Trim whitespace
  charly_api "trim", TString do |value|
    return TString.new(value.value.strip)
  end

  # Convert a string to a numeric
  charly_api "to_numeric", TString do |value|
    num = value.value.gsub("_", "").to_f64?(strict: false)

    if num.is_a? Float64
      return TNumeric.new(num)
    else
      return TNumeric.new(Float64::NAN)
    end
  end

  # Return the codepoints of a string as an array
  charly_api "ord", TString do |value|
    value = value.value

    result = TArray.new([] of BaseType)
    value.bytes.each do |byte|
      result.value << TNumeric.new(byte)
    end
    return result
  end
end
