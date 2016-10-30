class String

  # Indent a string with *prefix*, *amount* times
  #
  # ```
  # "hello".indent(2, "$")
  # # => "$$hello"
  # ```
  def indent(amount : Int32, prefix : String)
    self.each_line.map {|line|
      (prefix * amount) + line
    }.join ""
  end
end
