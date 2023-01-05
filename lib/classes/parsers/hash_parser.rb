# frozen_string_literal: true

module SidekiqLauncher
  # This class validates if a given string object represents a hash
  # and casts it as such
  class HashParser
    # Tries to parse the given value
    # If unable to do so, returns nil
    def try_parse(val)
      return unless validate?(val)

      begin
        eval(val) # rubocop:disable Security/Eval
      rescue SyntaxError, StandardError
        nil
      end
    end

    # Checks if the passed string matches and is convertible to
    # the expected type
    def validate?(string_val)
      !string_val.match(/\A\{.*\}\Z/).nil?
    end
  end
end
