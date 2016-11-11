require "../**"

module Charly::Internals

  # Sleeps for *time* seconds
  charly_api "stdout_print", variadic: true do
    arguments.each do |arg|
      STDOUT.puts arg.to_s
      STDOUT.flush
    end
    return TNull.new
  end
end
