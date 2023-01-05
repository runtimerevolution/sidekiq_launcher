# frozen_string_literal: true

require 'classes/parsers/array_parser'
require 'classes/parsers/bool_parser'
require 'classes/parsers/hash_parser'
require 'classes/parsers/int_parser'
require 'classes/parsers/number_parser'

module SidekiqLauncher
  # This class has the to validate and cast a given String to a defined variable type
  class TypeParser
    # Tries to cast the passed value as the passed type
    # If unable to, returns nil
    # rubocop:disable Metrics/CyclomaticComplexity
    def try_parse_as(val, type)
      case type&.to_sym
      when :string
        val
      when :integer
        IntParser.new.try_parse(val)
      when :number
        NumberParser.new.try_parse(val)
      when :boolean
        BoolParser.new.try_parse(val)
      when :array
        ArrayParser.new.try_parse(val)
      when :hash
        HashParser.new.try_parse(val)
      end
    end
    # rubocop:enable Metrics/CyclomaticComplexity
  end
end
