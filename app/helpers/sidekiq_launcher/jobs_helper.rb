# frozen_string_literal: true

require 'validations/job_contract'
require 'classes/job'

module SidekiqLauncher
  # This helper encapsulates all logic used to list and run sidekiq jobs from views
  module JobsHelper
    # Lists the possible types of arguments accepted by a sidekiq job
    def arg_types
      Job.list_arg_types
    end

    # Retrieves the list of sidekiq jobs and all their properties
    def sidekiq_jobs
      SidekiqLauncher.jobs
    end

    # Runs the passed sidekiq job with the passed arguments
    # Returns appropraite feedback messages
    def run_job(params)
      # TODO: Checking if in list when validating + checking if in list to use below

      args = build_arguments(params)
      validated = JobContract.new.call(job_class: params[:job_class], arguments: args)

      if validated.success?
        job = SidekiqLauncher.jobs.find { |j| j.job_class.to_s == params[:job_class] }

        # Placing params in order. The order is taken from their specification
        job_params = []
        job.parameters.each do |job_spec|
          current_arg = args.find { |ag| ag[:name].to_s.eql?(job_spec[:name].to_s) }
          job_params << cast_value(current_arg[:value], current_arg[:type].to_sym)
        end

        Sidekiq::Client.push('class' => job.job_class, 'args' => job_params)

        { success: true, messages: ["Sidekiq job #{params[:job_class]} started successfully."] }
      else
        { success: false, messages: validated.errors.map { |err| "#{err.path} #{err.text}" } }
      end
    end

    private

    # Builds an array of arguments from the passed parameters to be fed
    # to the job contract validator
    def build_arguments(params)
      args = []
      incoming_args = params.each.select { |a| a[0]&.include?('arg_name_') }

      incoming_args.each do |a|
        arg_index = a[0]&.delete_prefix('arg_name_')
        args << {
          name: params["arg_name_#{arg_index}"],
          value: params["arg_value_#{arg_index}"],
          type: params["arg_type_#{arg_index}"]
        }
      end

      args
    end

    def cast_value(val, type)
      case type
      when :integer
        val.to_i
      when :number
        val.to_f
      when :boolean
        val.in?(%w[true false 1 0])
      when :array
        JSON.parse(val) # TODO: [1, 2, 3, 4, 'cenas' ] is not parsable -> doc it so the user knows
      when :hash
        # TODO:
      else
        val
      end
    end
  end
end
