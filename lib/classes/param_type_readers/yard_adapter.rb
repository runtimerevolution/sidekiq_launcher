# frozen_string_literal: true

require_relative 'i_param_type_adapter'
require 'classes/job'

module ParamTypeReaders
  # Checks expected parameter types for the passed job, declared in the matching Yard doc
  class YardAdapter < IParamTypeAdapter
    def initialize(file_path)
      super
      file = "#{Rails.root}#{file_path}"
      return unless File.exist?(file)

      @param_types = read_param_types(file)
    end

    # This adapter is only valid if we were able to find type definitions
    def available?
      @param_types&.count&.positive? ? self : nil
    end

    # Returns the param types allowed for the passed parameter
    def allowed_types_for(param_name)
      @param_types[param_name] || SidekiqLauncher::Job.list_arg_types
    end

    private

    # Builds the list of parameter types from the Yard docs of the :perform function
    def read_param_types(file)
      result = {}
      reading = false

      File.readlines(file).reverse.each do |line|
        if line.include?('def perform')
          reading = true
          next
        end

        if reading
          if line.include?('@param')
            param_name = read_param_name(line)
            types_line = read_types(line)

            types = build_types_from_line(types_line)
            result[param_name] = types

          # Once we reach the end of the doc block (we are reading from bottom to top)
          elsif line == "\n"
            break
          end
        end
      end

      result
    end

    # Interprets the param name from the passed line
    def read_param_name(line)
      line.match(/@param .*? /).to_s.split&.second || ''
    end

    # Interprets the declared variable types from the passed line
    def read_types(line)
      # Retrieving types specification and clearing array types
      line.match(/\[.*?\]/).to_s.gsub(/<.*?>/, '')
    end

    # Builds an array of types from a line describing allowed types for the parameter
    def build_types_from_line(line)
      result = []
      result << :array if line.include?('Array')
      result << :integer if line.include?('Integer')
      result << :number if line.include?('Numeric')
      result << :boolean if line.include?('Boolean')
      result << :hash if line.include?('Hash')
      result << :string if line.include?('String')
      result
    end
  end
end
