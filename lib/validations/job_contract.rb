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
        required(:type).filled(:string)
      end
    end

    rule(:job_class) do
      err_msg = "Unable to run #{value} Sidekiq job"

      key.failure("#{err_msg}: Job not loaded.") unless JobLoader.job_props(value).present?
      begin
        job_class = value.constantize
        key.failure("#{err_msg}: Method perform_async not found.") unless job_class.methods.include?(:perform_async)
      rescue StandardError
        key.failure("#{err_msg}: Class not found.")
      end
    end

    rule(:arguments) do
      job = JobLoader.job_props(values[:job_class])
      key.failure("Job #{values[:job_class]} is not loaded.") unless job.present?

      value.each do |arg|
        job_param = job&.param_specs(arg[:name])

        if job_param.present?
          # checking if passed type exists in list of allowed types
          unless arg[:type].to_sym.in?(job_param[:allowed_types])
            key.failure("Argument type #{arg[:type]} for argument #{arg[:name]} does not exist")
          end

          # Preventing implicit conversion errors
          val = (arg[:value].is_a?(String) ? arg[:value].to_s : arg[:value]) || ''

          # Failing empty required arguments
          key.failure("Parameter #{arg[:name]} is required") if job_param[:required] == true &&
                                                                (!val.present? || val.delete(' ').eql?(''))
        else
          key.failure("#{values[:job_class]}.perform does not contain a parameter named #{arg[:name]}")
        end
      end
    end
  end
end
