# frozen_string_literal: true

require_relative 'param_type_readers/default_adapter'
require_relative 'param_type_readers/rbs_adapter'
require_relative 'param_type_readers/yard_adapter'

module SidekiqLauncher
  # This class represents a wrapper for a Sidekiq job, containing all its properties
  # and specifications of its parameters
  class Job
    attr_reader :job_class, :file_path, :parameters

    # Retrieves the possible types of arguments accepted by a sidekiq job.
    # Types are defined as per the sidekiq's documentation on 20 Dec 2022:
    # https://github.com/mperham/sidekiq/wiki/The-Basics
    #
    # @return [Array<Sym>] An array containing all valid parameter types to run Sidekiq jobs
    def self.list_arg_types
      %i[string integer number boolean array hash]
    end

    def initialize(job_class)
      root_folder = Rails.application.class.module_parent_name.underscore
      @job_class = job_class
      @file_path = job_class.instance_method(:perform).source_location[0]&.split(root_folder)&.last || 'File not found'
      @param_types_reader = find_param_types_reader
      @parameters = build_param_details
    end

    # Retrieves the specifications / properties of the specified parameter or nil if parameter does not exist
    #
    # @param param_name [<String>] The name of the parameter
    # @return [Hash { name: String, required: Boolean, psition: Integer, allowed_types: Array<Sym> }] The specifications
    # of the passed parameter
    def param_specs(param_name)
      @parameters&.find { |p| p.fetch(:name, '--') == param_name }
    end

    # Build this job's parameters as an array of values with the expected types
    # This array is properly ordered as per the job's parameters
    #
    # @param args [Array<Hash { name: String, value: String, type: String }>] The list of arguments from the input
    # @return [Array<Hash { success: Boolean, errors: Array<String>, params: Array<Undefined> }>] <description>
    def build_perform_params(args)
      result = []
      errors = []

      # NOTE: parameters are retrieved in order,  which we must respect
      parameters.each do |param_specs|
        param_name = param_specs.fetch(:name, '-')
        matching_input = find_param_in_arg_list(args, param_name)

        unless matching_input.present?
          errors << "Parameter :#{param_name} not found"
          next
        end

        # We cast the parameter to the passed type. Type should already be validated and known to be
        # in the list of allowed types
        param_value = parse_param_value(matching_input)

        if param_value.nil?
          errors << "Argument #{matching_input.fetch(:name, 'unknown')} is not a valid " \
                    "#{matching_input.fetch(:type, 'undefined type')}"
        else
          result << param_value
        end
      end

      { success: errors.empty?, errors: errors, params: errors.empty? ? result : nil }
    end

    private

    # Build the specification for the parameters of the perform method of the sidekiq job class
    #
    # @return [Array<Hash { name: String, required: Boolean, psition: Integer, allowed_types: Array<Sym> }>] A list with
    # the specification of all parameters for this job
    def build_param_details
      result = []
      begin
        @job_class.new.method(:perform).parameters.each_with_index do |param, i|
          result << {
            name: param[1].to_s,
            required: param[0].to_s.include?('req'),
            position: i,
            allowed_types: @param_types_reader.allowed_types_for(param[1].to_s)
          }
        end
      rescue StandardError => e
        puts("ERROR: Unable to find method :perform for class #{job_class}: #{e.message}")
      end

      result
    end

    # Picks a parameter type reader for the current job, depending on what
    # is available to it
    #
    # @return [IParamTypeReader] Adapter that reads parameter specifications for this sidekiq job
    def find_param_types_reader
      SidekiqLauncher::ParamTypeReaders::RbsAdapter.new(@file_path).available? ||
        SidekiqLauncher::ParamTypeReaders::YardAdapter.new(@file_path).available? ||
        SidekiqLauncher::ParamTypeReaders::DefaultAdapter.new
    end

    # Finds the parameter with the passed name from the list of input arguments
    def find_param_in_arg_list(args, name)
      args.find { |ag| ag.fetch(:name, '').to_s.eql?(name.to_s) }
    end

    # Parses the parameter value
    def parse_param_value(matching_input)
      return unless matching_input.fetch(:value, nil).present? && matching_input.fetch(:type, nil).present?

      TypeParser.new.try_parse_as(matching_input.fetch(:value), matching_input.fetch(:type))
    end
  end
end
