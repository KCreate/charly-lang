require "./syntax/location.cr"

module Charly
  class BaseException < Exception
    property location_start : Location
    property location_end : Location

    def initialize(@location_start, @location_end, @message)
    end

    def self.new(location_start, message)
      self.new(location_start, location_start, message)
    end
  end

  class SyntaxError < BaseException
  end
end
