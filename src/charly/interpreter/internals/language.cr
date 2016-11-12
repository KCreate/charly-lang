require "../**"

module Charly::Internals

  # Load a core module or a file
  charly_api "require", filename : TString do
    return TNull.new
  end

  # Resolve a filename to a absolute path
  charly_api "require_resolve", filename : TString do
    cwd = File.dirname(call.location_start.filename)
    path = Charly::Require.resolve(filename.value, cwd)
    return TString.new(path)
  end

end
