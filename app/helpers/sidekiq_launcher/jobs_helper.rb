# frozen_string_literal: true

require 'classes/job_loader'
require 'classes/job'
require 'validations/job_contract'
require 'classes/type_parser'

module SidekiqLauncher
  # This helper encapsulates all logic used to list and run sidekiq jobs from views
  module JobsHelper
    # Checks if Sidekiq gem is installed or not
    #
    # @return [Boolean] True if Sidekiq gem is installed
    def sidekiq_installed?
      SidekiqLauncher.sidekiq_installed?
    end

    # Retrieves the list of Sidekiq jobs and all their properties
    #
    # @return [Array<Job>] List of Sidekiq jobs
    def sidekiq_jobs
      JobLoader.jobs
    end

    # Runs the passed sidekiq job with the passed arguments
    #
    # @param params [Hash] Parameters from UI input
    # @param run_job [Boolean] True to actually run the job. True by default
    # @return [Hash { success: Boolean, messages: Array<String> }]
    def run_job(params, run_job: true)
      args = prep_params_input(params)
      validation = JobContract.new.call(job_class: params[:job_class], arguments: args)

      if validation.success?
        job = JobLoader.job_props(params[:job_class])
        params_data = build_job_params(job, args)

        if params_data[:success]
          Sidekiq::Client.push('class' => job.job_class, 'args' => params_data[:params]) if run_job
          { success: true, messages: ["Sidekiq job #{params[:job_class]} started successfully."] }
        else
          { success: false, messages: params_data[:errors] }
        end
      else
        { success: false, messages: validation_error_messages(validation) }
      end
    end

    private

    # Builds an array of arguments from the passed input parameters to be fed
    # to the job contract validator
    #
    # @param params [Hash] Parameters from UI input
    # @return [Array<Hash { name: String, value: String, type: String }>] Array of user inputs for each parameter
    def prep_params_input(params)
      args = []
      incoming_args = params.each.select { |a| a[0]&.include?('arg_name_') }

      incoming_args.each do |a|
        arg_index = a[0]&.delete_prefix('arg_name_')
        prepared_input = build_input_param(params, arg_index)
        args << prepared_input if prepared_input.present?
      end

      args
    end

    # Builds a single parameter input entry from the passed inputs
    #
    # @param params [Hash] Parameters from UI input
    # @param arg_index [Integer] The index of the parameter
    # @return [Hash, nil] A hash with a treated parameter with all required data or nil if all\
    # elements are not present
    def build_input_param(params, arg_index)
      arg_name = params["arg_name_#{arg_index}"]
      arg_val = params["arg_value_#{arg_index}"]
      arg_type = params["arg_type_#{arg_index}"]
      return unless arg_name.present? && arg_val.present? && arg_type.present?

      { name: arg_name, value: arg_val, type: arg_type }
    end

    # Build the job's parameters as an array of parameters with the expected types
    # This array is properly ordered as per the job's parameters
    #
    # @param job [Job] The Sidekiq job with expected parameters
    # @param args [Array<Hash { name: String, value: String, type: String }>] The list of arguments from the input
    # @return [Array<Hash { success: Boolean, errors: Array<String>, params: Array<Undefined> }>] <description>
    def build_job_params(job, args)
      result = []
      errors = []

      # NOTE: job.parameters are retrieved in order
      job&.parameters&.each do |param_specs|
        param_name = param_specs[:name]
        matching_input = find_param_in_input(args, param_name)

        unless matching_input.present?
          errors << "Parameter :#{param_name} not found"
          next
        end

        # We cast the parameter to the passed type. Type is already validated and we know it to be
        # in the list of allowed types
        param_value = parse_param_value(matching_input)

        if param_value.present?
          result << param_value
        else
          errors << "Argument #{matching_input[:name]} is not a valid #{matching_input[:type]}"
        end
      end

      { success: errors.empty?, errors: errors, params: errors.empty? ? result : nil }
    end

    # Finds the parameter with the passed name from the list of input arguments
    def find_param_in_input(args, name)
      args.find { |ag| ag[:name].to_s.eql?(name.to_s) }
    end

    # Parses the parameter value
    def parse_param_value(matching_input)
      return unless matching_input&.[](:value).present? && matching_input&.[](:type).present?

      TypeParser.new.try_parse_as(matching_input[:value], matching_input[:type])
    end

    # Returns an array with all validation errors to be presented to the user in the UI
    def validation_error_messages(validation)
      validation&.errors&.map { |err| "#{err.path} #{err.text}" }
    end
  end
end
