# frozen_string_literal: true

require 'dry/validation'
require 'classes/job_loader'

module SidekiqLauncher
  # This contract validates all elements of a job before running it
  # with Sidekiq
  class JobContract < Dry::Validation::Contract
    params do
      required(:job_class).filled(:string)
      optional(:arguments).array(:hash) do
        required(:name).filled(:string)
        required(:value)
        required(:type).filled(:symbol)
      end
    end

    rule(:job_class) do
      err_msg = "Unable to run #{value} Sidekiq job"

      key.failure("#{err_msg}: Job not loaded.") unless JobLoader.job_by_name(value).present?
      begin
        job_class = value.constantize
        key.failure("#{err_msg}: Method perform_async not found.") unless job_class.methods.include?(:perform_async)
      rescue StandardError
        key.failure("#{err_msg}: Class not found.")
      end
    end

    rule(:arguments) do
      job_class_name = values.fetch(:job_class, 'unknown')
      job = JobLoader.job_by_name(job_class_name)
      key.failure("Job #{job_class_name} is not loaded.") unless job.present?

      value.each do |arg|
        arg_name = arg.fetch(:name, '')
        job_param = job&.param_specs(arg_name)

        if job_param.present?
          # checking if passed type exists in list of allowed types
          unless arg.fetch(:type, 'no_type').in?(job_param.fetch(:allowed_types, []))
            key.failure("Argument type #{arg.fetch(:type, 'undefined')} for argument #{arg_name} " \
                        'does not exist')
          end

          # Preventing implicit conversion errors
          arg_val = arg.fetch(:value, '')
          val = (arg_val.is_a?(String) ? arg_val.to_s : arg_val)

          # Failing empty required arguments
          key.failure("Parameter #{arg_name} is required") if job_param.fetch(:required, true) == true &&
                                                              (!val.present? || val.delete(' ').eql?(''))
        else
          key.failure("#{job_class_name}.perform does not contain a parameter named #{arg_name}")
        end
      end
    end
  end
end
