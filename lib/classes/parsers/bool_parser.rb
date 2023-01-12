# frozen_string_literal: true

module SidekiqLauncher
  # This class validates if a given string object represents a boolean
  # and casts it as such
  class BoolParser
    # Tries to parse the given value
    #
    # @param val [String] The value to be parsed
    # @return [Boolean, nil] The parsed value or nil
    def try_parse(val)
      return unless validate?(val)

      val.in?(%w[true 1])
    end

    # Checks if the passed string matches and is convertible to
    # the expected type
    #
    # @param string_val [String] The value to be parsed
    # @return [Boolean] True if parsing is possible
    def validate?(string_val)
      string_val.in?(%w[true false 1 0])
    end
  end
end
