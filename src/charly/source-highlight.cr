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
      color_range = @location_start.row..@location_end.row
      print_range = Math.max(0, @location_start.row - LOOKBACK_ROW)..(@location_end.row + LOOKFORWARD_ROW)

      # Highlight the source
      highlighted_source = source.each_char.map_with_index { |char, index|
        if color_pos_range.covers? index
          char.colorize(:white).back(:red)
        else
          char.colorize.mode(:dim)
        end
      }.join("")

      # Append line number to the beginning
      lines = highlighted_source.each_line
      lines.each_with_index do |line, index|
        line = line.rstrip

        if print_range.covers? index

          unless print_range.first == index
            io << "\n"
          end

          if color_range.covers? index
            io << "-> ".colorize(:yellow)
            io << (index + 1).to_s.rjust(4).colorize(:yellow).mode(:bold)
            io << ".".colorize(:yellow).mode(:bold)
          else
            io << "   "
            io << (index + 1).to_s.rjust(4).colorize(:yellow).mode(:dim)
            io << ".".colorize(:yellow).mode(:dim)
          end
          io << ' '
          io << line
          io << "\e[0m"
        end
      end

      io << '\n'
    end
  end
end
