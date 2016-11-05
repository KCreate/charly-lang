# `Table` presents a two-dimensional array as a nice looking table
class Table

  # The resulting string is yielded
  def self.present(headers : Array(String), data : Array(Array(String)))
    io = MemoryIO.new

    data_size = 0
    data.each_with_index do |entry, index|
      if data_size == 0
        data_size = entry.size
      elsif entry.size != data_size
        raise "Invalid data amount at #{index}"
      end
    end

    if data_size == 0
      data_size = headers.size
    end

    # Check that there are enough headers
    if headers.size != data_size
      raise "Expected #{data_size} headers, got #{headers.size}"
    end

    # Append the headers to the data so we can get the correct cell spacing
    data.unshift headers
    cell_spacing = Array(Int32).new(headers.size, 0)

    # Iterate over all entries
    data.each do |row|
      row.each_with_index do |cell, index|
        cell_spacing[index] = cell.size if cell_spacing[index] < cell.size
      end
    end

    # Pop the header row off the data
    data.shift

    # Print the header row
    self.render_divider(cell_spacing, io)
    self.render_row(cell_spacing, headers, io)
    self.render_divider(cell_spacing, io)

    # Render all rows
    data.each do |row|
      self.render_row(cell_spacing, row, io)
    end
    self.render_divider(cell_spacing, io)

    yield io.to_s
  end

  # Renders a divider with *spacing* into *io*
  protected def self.render_divider(spacing : Array(Int32), io : IO)
    spacing.each do |width|
      io << "+"
      io << "-" * (width + 2)
      io << ""
    end
    io << "+\n"
  end

  # Renders *data* with the given cell spacing into *io*
  protected def self.render_row(spacing : Array(Int32), data : Array(String), io : IO)
    if spacing.size != data.size
      raise "Header cell count and cell spacing count don't match"
    end

    data.each_with_index do |entry, index|
      width = spacing[index]

      io << "| "
      io << entry.ljust(width, ' ')
      io << " "
    end
    io << "|\n"
  end
end
