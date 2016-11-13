require "../**"
require "colorize"

module Charly::Internals

  # Colorizes *string* with *code*
  charly_api "colorize", target : TString, code : TNumeric do
    return TString.new("\e[#{code.value.to_i64}m#{target}\e[0m")
  end

end
