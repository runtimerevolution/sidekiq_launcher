# frozen_string_literal: true

module SidekiqLauncher
  # This class represents a wrapper for a Sidekiq job, containing all its properties
  # and specifications of its parameters
  class Job
    attr_reader :job_class, :file_path, :parameters

    # Retrieves the possible types of arguments accepted by a sidekiq job
    # Types are defined as per the sidekiq's documentation on 20 Dec 2022:
    # https://github.com/mperham/sidekiq/wiki/The-Basics
    def self.list_arg_types
      %i[string integer number boolean array hash]
    end

    def initialize(job_class)
      root_folder = Rails.application.class.module_parent_name.underscore

      @job_class = job_class
      @file_path = Class.const_source_location(job_class.to_s)[0]&.split(root_folder)&.last || 'File not found'
      @parameters = build_param_details
    end

    # Retrieves the specifications / properties of the specified parameter
    # or nil if parameter does not exist
    def param_specs(param_name)
      @parameters&.find { |p| p[:name] == param_name }
    end

    private

    # Build the specification for the parameters of the perform method
    # of the sidekiq job class
    def build_param_details
      result = []
      begin
        @job_class.new.method(:perform).parameters.each_with_index do |param, i|
          result << {
            name: param[1].to_s,
            required: param[0].to_s.include?('req'),
            position: i,
            allowed_types: find_allowed_types(param[1])
          }
        end
      rescue StandardError => e
        puts("ERROR: Unable to find method :perform for class #{job_class}: #{e.message}")
      end

      result
    end

    # Defines the type of the passed parameter in case it is defined
    # Looks for both RBS or Swagger for hints of type definition
    # If unable to find the type, returns nil, and it becomes the user's responsibility
    # to define this parameter's type
    def find_allowed_types(param_name)
      build_param_type_defs
      allowed_types(param_name.to_s)
    end

    # Returns an array with the lines containing parameter definitions
    def build_param_type_defs
      # We only search for the file once
      return if @sig_file_path.present?

      @sig_file_path = "#{@file_path.delete_prefix('/app/').delete_suffix('.rb')}.rbs"
      sig_file = Rails.root.join('sig', @sig_file_path)
      return unless File.exist?(sig_file)

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

      @param_type_defs = build_param_types_list(type_lines)
    end

    # Creates an array of type definitions from the array of lines
    def build_param_types_list(type_lines)
      type_lines = type_lines.join(' ')
      type_lines = type_lines.delete_prefix("#{type_lines.split('(').first}(")
      type_lines = type_lines.delete_suffix(")#{type_lines.split(')').last}")
      type_lines.split(',')
    end

    # Retrieves the type for the passed parameter
    def allowed_types(param_name)
      return Job.list_arg_types unless @param_type_defs.present?

      type_def = @param_type_defs.grep(/.*#{param_name}\Z/).first
      return build_allowed_types_from_def(type_def) if type_def.present?

      Job.list_arg_types
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
