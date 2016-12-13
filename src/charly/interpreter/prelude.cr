module Charly

  # The path at which the prelude is located
  PRELUDE_PATH = File.real_path(ENV["CHARLYDIR"] + "/src/std/prelude.ch")

  class PreludeLoader
    def self.load(path, arguments, flags)
      scope = Scope.new

      scope.init("ARGV", load_arguments(arguments), true)
      scope.init("IFLAGS", load_flags(flags), true)
      scope.init("ENV", load_env, true)

      scope
    end

    private def self.load_arguments(arguments)
      argv = [] of BaseType
      arguments.each do |arg|
        argv << TString.new arg
      end
      TArray.new argv
    end

    private def self.load_flags(flags)
      iflags = [] of BaseType
      flags.each do |flag|
        iflags << TString.new flag
      end
      TArray.new iflags
    end

    private def self.load_env
      object = TObject.new
      ENV.each do |key, value|
        object.data.init(key, TString.new(value), true)
      end
      object
    end
  end
end
