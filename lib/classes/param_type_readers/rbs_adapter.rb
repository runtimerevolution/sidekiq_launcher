# frozen_string_literal: true

require_relative 'i_param_type_adapter'
require 'classes/job'

module ParamTypeReaders
  # Checks expected parameter types for the passed job, declared in the matching .rbs file
  class RbsAdapter < IParamTypeAdapter
    def initialize(file_path)
      super
      sig_file_path = "#{file_path.delete_prefix('/app/').delete_suffix('.rb')}.rbs"
      sig_file = Rails.root.join('sig', sig_file_path)
      return unless File.exist?(sig_file)

      @param_types = build_param_types(sig_file)
    end

    # Checks if the current job is available to use the RBS adapter
    #
    # @return [self, nil] Returns self or nil depending on if the Sidekiq Job meets the requirements for the adapter
    def available?
      @param_types&.count&.positive? ? self : nil
    end

    # Returns an array with the allowed types for the passed parameter
    # If unable to find any, should return the default list
    # from SidekiqLauncher::Job.list_arg_types
    #
    # @param _param_name [String] The name of the parameter to be checked
    # @return [Array<Sym>] List of specified types for the passed parameter
    def allowed_types_for(param_name)
      @param_types[param_name] || SidekiqLauncher::Job.list_arg_types
    end

    private

    # Builds the list of parameter types for every parameter
    #
    # @param sig_file [String] The path to the *.rbs file
    # @return [Hash { String: Array<Sym> }] A map containing type specifications for every parameter
    def build_param_types(sig_file)
      result = {}
      types_list = read_types_from_file(sig_file)
      types_list.each do |entry|
        param_name = entry.split.last
        result[param_name] = build_allowed_types_from_def(entry)
      end
      result
    end

    # Reads the list of parameter types for a single parameter
    #
    # @param sig_file [String] The path to the *.rbs file
    # @return [Array<String>] A non curated list of type specifications for every parameter
    def read_types_from_file(sig_file)
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

    # Build a curated list of allowed types from the parameter's type description
    #
    # @param type_def [Array<String>] A non curated list of type specifications for every parameter
    # @return [Array<Sym>] The list of type specifications for every parameter
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
