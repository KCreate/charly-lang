# This file was extracted and adapted from the crystal compiler
# Original: https://github.com/crystal-lang/crystal/blob/master/src/compiler/crystal/config.cr

module Charly

  module Config
    VERSION = "0.0.1"
    @@sha : String?

    def self.description
      commit_sha = get_sha
      if commit_sha
        "Charly #{VERSION} [#{commit_sha}] (#{date})"
      else
        "Charly #{VERSION} (#{date})"
      end
    end

    def self.get_sha
      @@sha ||= compute_sha
    end

    private def self.compute_sha
      git_version = {{ `(git describe --tags --long --always 2>/dev/null) || true`.stringify.chomp }}

      if git_version.empty?
        return
      end

      _, _, sha = git_version.split("-")
      sha = sha[1..-1] # Remove the g from the beginning
      return sha
    end

    def self.date
      {{ `date +'%d. %B %Y'`.stringify.chomp }}
    end
  end

end
