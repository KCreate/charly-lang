require "../**"

module Charly::Internals

  charly_api "__charly_config", name : TString do
    return case name.value
    when "LICENSE"
      TString.new ::Charly::Config::LICENSE
    when "VERSION"
      TString.new ::Charly::Config::VERSION
    when "COMPILE_COMMIT"
      commit_sha = ::Charly::Config.get_sha
      if commit_sha
        TString.new commit_sha
      else
        TNull.new
      end
    when "COMPILE_DATE"
      TString.new ::Charly::Config::COMPILE_DATE
    else
      TNull.new
    end
  end

end
