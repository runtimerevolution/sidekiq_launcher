# frozen_string_literal: true

module SidekiqLauncher
  # This helper encapsulates all logic used to list and run sidekiq jobs from views
  module JobsHelper
    # Retrieves the possible types of arguments accepted by a sidekiq job
    # Types are defined as per the sidekiq's documentation on 20 Dec 2022:
    # https://github.com/mperham/sidekiq/wiki/The-Basics
    def list_arg_types
      # TODO: Add Array of <T>???
      %i[string integer number boolean array hash]
    end

    # Retrieves the list of sidekiq jobs and all their properties
    def sidekiq_jobs
      SidekiqLauncher.jobs
    end

    # Runs the passed sidekiq job with the passed arguments
    # Returns appropraite feedback messages
    def run_job(params)

      # FIXME: Redo using jobs in memory
      # TODO: Try to remove casts!

      args = build_arguments(params)
      validated = JobContract.new.call(job_class: params[:job_class], arguments: args)

      if validated.success?
        job_class = params[:job_class].constantize
        params_specs = params_specification(job_class)

        # TODO: what about named params? And non named? (must keep order) - read params_specs to solve
        # TODO: Present link to sidekiq queue
        # TODO: Return failure if something happens when triangulating / casting ?

        # Placing params in order. The order is taken from their specification
        job_params = []
        args.each_with_index do |_ag, i|
          positioned_param = params_specs.find { |ps| ps[:position] == i }
          current_arg = args.find { |ag| ag[:name].to_s.eql?(positioned_param[:name].to_s) }
          job_params << cast_value(current_arg[:value], current_arg[:type].to_sym)
        end

        Sidekiq::Client.push('class' => job_class, 'args' => job_params)

        # TODO: check if process actually started and is queued
        # TODO: TEST: Try to run job with a hash -> check the logs

        success = true
        messages = ["Sidekiq job #{params[:job_class]} started successfully."]
      else
        success = false
        messages = []
        validated.errors.each do |err|
          messages << "#{err.path} #{err.text}"
        end
      end

      { success: success, messages: messages }
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
