# frozen_string_literal: true

require 'classes/parsers/array_parser'
require 'classes/parsers/bool_parser'
require 'classes/parsers/hash_parser'
require 'classes/parsers/int_parser'
require 'classes/parsers/number_parser'

module SidekiqLauncher
  # TODO: Consider using dry-rb types for validation and parsing

  # This class has the to validate and cast a given String to a defined variable type
  class TypeParser
    # Casts the passed value as the passed type
    #
    # @param val [String] The value to be parsed
    # @param type [Sym] The type to parse the value as
    # @return [String, Integer, Number, Boolean, Array, Hash, nil] The value, parsed as the chosen type or nil if value
    # is not parseable
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
