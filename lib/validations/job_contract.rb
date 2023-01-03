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
      err_msg = "#{value} is not a valid Sidekiq job class"
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
        unless arg[:type].to_sym.in?(JobsController.helpers.list_arg_types)
          key.failure("Argument type #{arg[:type]} for argument #{arg[:name]} does not exist")
        end

        # Preventing implicit conversion errors
        val = (arg[:value].is_a?(String) ? arg[:value].to_s : arg[:value]) || ''

        required = job_p[0].to_s.include?('req')
        if val.delete(' ').eql?('') || !val.present?
          # Skipping empty non required arguments
          next unless required

          # Failing empty required arguments
          key.failure("Parameter #{arg[:name]} is required") if required
        end

        validated = case arg[:type]
                    when 'string'
                      true
                    when 'integer'
                      !val.match(/^(\d)+$/).nil?
                    when 'number'
                      !val.match(/\A[+-]?\d+(\.\d+)?\z/).nil?
                    when 'boolean'
                      val.in?(%w[true false 1 0])
                    when 'array'
                      # TODO: Trying to cast as hash breaks if not JSON compatible (user uses '', for example)
                      val.starts_with?('[') && val.ends_with?(']')
                    when 'hash'
                      val.starts_with?('{') && val.ends_with?('}')
                    else
                      false
                    end

        key.failure("Argument #{arg[:name]} is not a valid #{arg[:type]}") unless validated
      end
    end
  end
end
