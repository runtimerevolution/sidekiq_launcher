# frozen_string_literal: true

require_relative 'i_param_type_adapter'
require 'classes/job'

module ParamTypeReaders
  # Checks expected parameter types for the passed job, declared in the matching .rbs file
  class RbsAdapter < IParamTypeAdapter
    def initialize(file_path)
      super
      @file_path = file_path
    end

    # Checks if the current job is available to use the RBS adapter
    def available?
      # We do not search for the file if we already built the list of parameter type definitions
      return self if @param_type_defs.present? && @param_type_defs.count.positive?

      sig_file_path = "#{@file_path.delete_prefix('/app/').delete_suffix('.rb')}.rbs"
      sig_file = Rails.root.join('sig', sig_file_path)
      return nil unless File.exist?(sig_file)

      @param_type_defs = build_param_types_list(sig_file)
      @param_type_defs.count.positive? ? self : nil
    end

    # Retrieves the type for the passed parameter
    def allowed_types_for(param_name)
      type_def = @param_type_defs&.grep(/.*#{param_name}\Z/)&.first
      return build_allowed_types_from_def(type_def) if type_def.present?

      SidekiqLauncher::Job.list_arg_types
    end

    private

    def build_param_types_list(sig_file)
      # Params definitions may include multiple lines
      reading_params = false
      type_lines = []
      File.readlines(sig_file).each do |line|
        reading_params = true if line.include?('perform:')

        if reading_params
          type_lines << line
          break if line.include?('->')
        end
      end

      # Cleaning up list of type definitions
      type_lines = type_lines.join(' ')
      type_lines = type_lines.delete_prefix("#{type_lines.split('(').first}(")
      type_lines = type_lines.delete_suffix(")#{type_lines.split(')').last}")
      type_lines.split(',')
    end

    # Build a list of allowed types from the parameter's type description
    def build_allowed_types_from_def(type_def)
      result = []
      # We must check array first, because it could be an array of type
      if type_def.include?('Array')
        result << :array
        # Removing types from array definitions. Ex:
        # "Array[Integer | String] | Integer" becomes "Array | Integer"
        type_def = type_def.gsub(/\[.*?\]/, '')
      end
      result << :integer if type_def.include?('Integer')
      result << :number if type_def.include?('Numeric')
      result << :boolean if type_def.include?('Boolean')
      result << :hash if type_def.include?('Hash')
      result << :string if type_def.include?('String')
      result
    end
  end
end
