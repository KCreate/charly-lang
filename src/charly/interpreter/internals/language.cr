require "../**"

module Charly::Internals

  # Load a core module or a file
  charly_api "require", filename : TString do
    begin
      cwd = File.dirname(call.location_start.filename)
      return Require.load(filename.value, cwd)
    rescue e : Require::FileNotFoundException
      raise RunTimeError.new(call, "Can't load file #{filename}")
    end
  end

  # Resolve a filename to a absolute path
  charly_api "require_resolve", filename : TString do
    cwd = File.dirname(call.location_start.filename)
    path = Require.resolve(filename.value, cwd)
    return TString.new(path)
  end

end
