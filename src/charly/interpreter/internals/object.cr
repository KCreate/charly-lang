require "../**"
require "colorize"

module Charly::Internals

  # Colorizes *string* with *code*
  charly_api "colorize", target : TString, code : TNumeric do
    return TString.new("\e[#{code.value.to_i64}m#{target}\e[0m")
  end

  # Returns a list of keys the objects internal state holds
  charly_api "_object_keys", object : DataType do
    keys = [] of BaseType

    object.data.dump_values(parents: false).each do |_, key|
      unless Visitor::DISALLOWED_VARS.includes? key
        keys << TString.new(key)
      end
    end

    return TArray.new(keys)
  end

  # Deletes the parent property of the objects internal state
  # thus removing it from the scope hierarchy
  charly_api "_isolate_object", object : TObject do
    object.data.parent = nil
    return object
  end

  # Returns the length of a given value
  #
  # Numeric -> The number itself
  # String -> The length of the string
  # TArray -> The amount of items the array contains
  # Else -> 0
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

  # Returns the memory address of a given value
  charly_api "_object_id", value : BaseType do
    return TNumeric.new value.object_id
  end
end
