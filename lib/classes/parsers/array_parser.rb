# frozen_string_literal: true

module SidekiqLauncher
  # This class validates if a given string object represents an array
  # and casts it as such
  class ArrayParser
    # Tries to parse the given value
    # If unable to do so, returns nil
    def try_parse(val)
      return unless validate?(val)

      # TODO: remove delete and use regex -> RIGHT NOW it is removing ALL [], even with arrays within arrays
      val.match(/[^\[\]]+/).split(',') # TODO: Regex is wrong
    end

    # Checks if the passed string matches and is convertible to
    # the expected type
    def validate?(string_val)
      !string_val.match(/\A\[.*\]\Z/).nil?
    end
  end
end
