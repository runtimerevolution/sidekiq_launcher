# frozen_string_literal: true

require 'dry/validation'

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

      key.failure("#{err_msg}: Job not loaded.") unless SidekiqLauncher.job_props(value).present?
      begin
        job_class = value.constantize
        key.failure("#{err_msg}: Method perform_async not found.") unless job_class.methods.include?(:perform_async)
      rescue StandardError
        key.failure("#{err_msg}: Class not found.")
      end
    end

    rule(:arguments) do
      # retrieving params so we can directly check their validity against the Sidekiq Job class
      perform_method = values[:job_class].constantize&.new&.method(:perform)
      key.failure("#{values[:job_class]} does not contain a method named perform") unless perform_method.present?

      value.each do |arg|
        job_p = perform_method&.parameters&.find { |p| p[1].to_s == arg[:name] }

        unless job_p.present?
          key.failure("#{values[:job_class]}.perform does not contain a parameter named #{arg[:name]}")
        end

        # checking if passed type exists in list of possible types
        unless arg[:type].to_sym.in?(Job.list_arg_types)
          key.failure("Argument type #{arg[:type]} for argument #{arg[:name]} does not exist")
        end

        # Preventing implicit conversion errors
        val = (arg[:value].is_a?(String) ? arg[:value].to_s : arg[:value]) || ''

        # Failing empty required arguments
        required = job_p[0].to_s.include?('req')
        key.failure("Parameter #{arg[:name]} is required") if required && (val.delete(' ').eql?('') || !val.present?)
      end
    end
  end
end
