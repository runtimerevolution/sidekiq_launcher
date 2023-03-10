# frozen_string_literal: true

module SidekiqLauncher
  # This class validates if a given string object represents an integer
  # and casts it as such
  class IntParser
    # Tries to parse the given value
    #
    # @param val [String] The value to be parsed
    # @return [Integer, nil] The parsed value or nil
    def try_parse(val)
      return unless validate?(val)

      begin
        val.to_i
      rescue SyntaxError, StandardError
        nil
      end
    end

    # Checks if the passed string matches and is convertible to
    # the expected type
    #
    # @param string_val [String] The value to be parsed
    # @return [Boolean] True if parsing is possible
    def validate?(string_val)
      !string_val.match(/^(-?\d)+$/).nil?
    end
  end
end
