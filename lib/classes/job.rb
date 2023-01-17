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
      @parameters&.find { |p| p[:name] == param_name }
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
  end
end
