# frozen_string_literal: true

module SidekiqLauncher
  # This class validates if a given string object represents an number / numeric entity
  # and casts it as such
  class NumberParser
    # Tries to parse the given value
    # If unable to do so, returns nil
    def try_parse(val)
      return unless validate?(val)

      begin
        val.to_f
      rescue SyntaxError, StandardError
        nil
      end
    end

    # Checks if the passed string matches and is convertible to
    # the expected type
    def validate?(string_val)
      !string_val.match(/\A[+-]?\d+(\.\d+)?\z/).nil?
    end
  end
end
