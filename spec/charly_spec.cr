require "./spec_helper"

describe Charly do
  it "runs the spec suite" do

    # Create the bin directory
    Process.run("mkdir", [
      "bin"
    ])

    # Build the interpreter
    Process.run("crystal", [
      "build",
      "src/charly.cr",
      "--release",
      "--stats",
      "-o",
      "bin/charly"
    ], output: STDOUT, input: STDIN, error: STDERR)

    # Set the environment variable for the std-lib
    Process.run("export", [
      "CHARLYDIR=./"
    ])

    # Run the spec
    result = Process.run("./bin/charly", [
      "test/main.charly"
    ], output: STDOUT, input: STDIN, error: STDERR)

    result.exit_status.should eq(0)
  end
end
