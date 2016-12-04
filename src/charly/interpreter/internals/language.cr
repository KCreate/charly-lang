require "../**"

module Charly::Internals

  # Load a core module or a file
  charly_api "require", filename : TString do
    begin
      cwd = File.dirname(call.location_start.filename)
      return Require.load(filename.value, cwd, visitor.prelude)
    rescue e : Require::FileNotFoundException
      raise RunTimeError.new(call, "Can't load #{filename}")
    end
  end

  # Load a core module or a file
  charly_api "require_no_prelude", filename : TString do
    begin
      cwd = File.dirname(call.location_start.filename)
      return Require.load(filename.value, cwd, visitor.prelude)
    rescue e : Require::FileNotFoundException
      raise RunTimeError.new(call, "Can't load #{filename}")
    end
  end

  # Resolve a filename to a absolute path
  charly_api "require_resolve", filename : TString do
    cwd = File.dirname(call.location_start.filename)
    path = Require.resolve(filename.value, cwd)
    return TString.new(path)
  end

  # Run a file in the same scope as the function call
  charly_api "__run", filename : TString do
    filename = filename.value

    begin
      cwd = File.dirname(call.location_start.filename)
      path = Require.resolve(filename, cwd)

      # Load the file content
      unless File.exists?(path) && File.readable?(path)
        raise RunTimeError.new(call.argumentlist[0], "Can't load #{filename}")
      end

      program = Parser.create(File.open(path), path)
      visitor.exec_program(program, scope)
      return TNull.new
    rescue e : Require::FileNotFoundException
      raise RunTimeError.new(call.argumentlist[0], "Can't load #{filename}")
    end
  end

end
