require "../**"
require "colorize"

module Charly::Internals

  # Colorizes *string* with *code*
  charly_api "colorize", target : TString, code : TNumeric do
    return TString.new("\e[#{code.value.to_i64}m#{target}\e[0m")
  end

  # Return a list of keys the object has
  charly_api "_object_keys", object : TObject do
    keys = [] of BaseType

    object.data.dump_values(parents: false).each do |_, key|
      unless Visitor::DISALLOWED_VARS.includes? key
        keys << TString.new(key)
      end
    end

    return TArray.new(keys)
  end
end
