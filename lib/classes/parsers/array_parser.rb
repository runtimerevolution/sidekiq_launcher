# frozen_string_literal: true

require 'rb_json5'

module SidekiqLauncher
  # This class validates if a given string object represents an array
  # and casts it as such
  class ArrayParser
    # Tries to parse the given value
    # If unable to do so, returns nil
    def try_parse(val)
      return unless validate?(val)

      # Using relaxed JSON parser to support hashes in arrays with symbols without quotes
      # If for some reason the gem is not available anymore, we use the standard JSON parse
      begin
        Object.const_defined?('RbJSON5') ? RbJSON5.parse(val) : JSON.parse(val)
      rescue SyntaxError, StandardError
        nil
      end
    end

    # Checks if the passed string matches and is convertible to
    # the expected type
    def validate?(string_val)
      !string_val.match(/\A\[.*\]\Z/).nil?
    end
  end
end