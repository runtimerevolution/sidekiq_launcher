# frozen_string_literal: true

require 'rb_json5'

module SidekiqLauncher
  # This class validates if a given string object represents a hash
  # and casts it as such
  class HashParser
    # Tries to parse the given value
    #
    # @param val [String] The value to be parsed
    # @return [Hash, nil] The parsed value or nil
    def try_parse(val)
      return unless validate?(val)

      # Using relaxed JSON parser to support hash symbols without quotes
      # If for some reason the gem is not available anymore, we use the standard JSON parse
      begin
        Object.const_defined?('RbJSON5') ? RbJSON5.parse(val) : JSON.parse(val)
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
      !string_val.match(/\A\{.*\}\Z/).nil?
    end
  end
end
