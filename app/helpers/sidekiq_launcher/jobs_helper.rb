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
      validation = JobContract.new.call(job_class: params.fetch(:job_class, nil), arguments: args)

      if validation.success?
        job = JobLoader.job_by_name(params.fetch(:job_class, nil))
        params_data = job&.build_perform_params(args)

        if params_data.fetch(:success, false)
          Sidekiq::Client.push('class' => job.job_class, 'args' => params_data.fetch(:params, [])) if run_job
          { success: true, messages: ["Sidekiq job #{params.fetch(:job_class, 'unknown')} started successfully."] }
        else
          { success: false, messages: params_data.fetch(:errors, []) }
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
        prepared_input = build_input_entry(params, arg_index)
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
    def build_input_entry(params, arg_index)
      arg_name = params["arg_name_#{arg_index}"]
      arg_val = params["arg_value_#{arg_index}"]
      arg_type = params["arg_type_#{arg_index}"]
      return unless arg_name.present? && arg_val.present? && arg_type.present?

      { name: arg_name, value: arg_val, type: arg_type.to_sym }
    end

    # Returns an array with all validation errors to be presented to the user in the UI
    def validation_error_messages(validation)
      validation&.errors&.map { |err| "#{err.path} #{err.text}" }
    end
  end
end
