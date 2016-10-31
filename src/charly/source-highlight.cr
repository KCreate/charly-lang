require "colorize"
require "./syntax/location.cr"

module Charly

  # Highlight a part of a file
  struct SourceHighlight
    LOOKBACK_ROW = 5
    LOOKFORWARD_ROW = 2

    property location_start : Location
    property location_end : Location

    def initialize(@location_start, @location_end)
    end

    # Write the highlighted *source* into *io*
    def present(source, io)

      # The range we need to color in red
      color_pos_range = @location_start.pos...(@location_end.pos + @location_end.length)
      print_range = (@location_start.row - LOOKBACK_ROW)..(@location_end.row + LOOKFORWARD_ROW)

      # Highlight the source
      source_io = MemoryIO.new(source)
      highlighted_source = source_io.to_s.each_char.map_with_index { |char, index|
        index += 2

        if color_pos_range.covers? index
          char.colorize(:white).back(:red)
        else
          char
        end
      }.join("")

      # Append line number to the beginning
      highlighted_source.each_line.each_with_index do |line, index|
        index += 1
        line = line.rstrip

        if print_range.covers? index
          io << "#{index}.".colorize(:yellow)
          io << ' '
          io << line
        else
          next
        end

        unless index == print_range.end
          io << '\n'
        end
      end

      io << '\n'
    end
  end
end
