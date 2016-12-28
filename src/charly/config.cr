# This file was extracted and adapted from the crystal compiler
# Original: https://github.com/crystal-lang/crystal/blob/master/src/compiler/crystal/config.cr

module Charly

  module Config
    VERSION = "0.0.1"
    COMPILE_DATE = {{ `date +'%d. %B %Y'`.stringify.chomp }}
    LICENSE = <<-LICENSETEXT
    The MIT License (MIT)

    Copyright (c) 2016 Leonard Schuetz

    Permission is hereby granted, free of charge, to any person obtaining a copy
    of this software and associated documentation files (the "Software"), to deal
    in the Software without restriction, including without limitation the rights
    to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
    copies of the Software, and to permit persons to whom the Software is
    furnished to do so, subject to the following conditions:

    The above copyright notice and this permission notice shall be included in
    all copies or substantial portions of the Software.

    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
    IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
    FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
    AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
    LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
    OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
    THE SOFTWARE.
    LICENSETEXT

    @@sha : String?

    def self.description
      commit_sha = get_sha
      if commit_sha
        "Charly #{VERSION} [#{commit_sha}] (#{COMPILE_DATE})"
      else
        "Charly #{VERSION} (#{COMPILE_DATE})"
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
  end

end
