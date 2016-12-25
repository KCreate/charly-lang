require "colorize"
require "./syntax/location.cr"

module Charly
  # Highlight a part of a file
  class SourceHighlight
    LOOKBACK_ROW         = 5
    LOOKFORWARD_ROW      = 2
    COLOR_HIGHLIGHT      = :white
    COLOR_HIGHLIGHT_BACK = :red
    COLOR_LINENR         = :white
    ERROR_POINTER        = "-> "

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
      # TODO: Switch back to each_char.map_with_index once crystal-lang#3767 is fixed
      index = 0
      highlighted_source = ""
      source.each_char do |char|
        if color_pos_range.covers? index
          highlighted_source += char.colorize(COLOR_HIGHLIGHT).back(COLOR_HIGHLIGHT_BACK).to_s
        else
          highlighted_source += char.colorize.mode(:dim).to_s
        end

        index += 1
      end

      # Append line number to the beginning
      lines = highlighted_source.each_line
      lines.each_with_index do |line, index|
        line = line.rstrip

        if print_range.covers? index
          unless print_range.first == index
            io << "\n"
          end

          if color_range.covers? index
            io << ERROR_POINTER.colorize(COLOR_LINENR)
            io << (index + 1).to_s.rjust(4).colorize(COLOR_LINENR).mode(:bold)
            io << ".".colorize(COLOR_LINENR).mode(:bold)
          else
            io << " " * ERROR_POINTER.size
            io << (index + 1).to_s.rjust(4).colorize(COLOR_LINENR).mode(:dim)
            io << ".".colorize(COLOR_LINENR).mode(:dim)
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
