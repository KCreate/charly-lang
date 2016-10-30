class String
  def indent(amount, prefix)
    self.each_line.map {|line|
      (prefix * amount) + line
    }.join ""
  end
end
