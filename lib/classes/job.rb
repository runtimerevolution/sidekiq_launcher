# frozen_string_literal: true

module SidekiqLauncher
  # This class represents a wrapper for a Sidekiq job, containing all its properties
  # and specifications of its parameters
  class Job
    attr_reader :job_class, :file_name, :parameters

    # Retrieves the possible types of arguments accepted by a sidekiq job
    # Types are defined as per the sidekiq's documentation on 20 Dec 2022:
    # https://github.com/mperham/sidekiq/wiki/The-Basics
    def self.list_arg_types
      %i[string integer number boolean array hash]
    end

    def initialize(job_class)
      @job_class = job_class
      @file_name = Class.const_source_location(job_class.to_s)[0]&.split('/')&.last || 'File not found'
      @parameters = build_param_details
    end

    private

    # Build the specification for the parameters of the perform method
    # of the sidekiq job class
    # TODO: type: nil is there to implement types from RBS
    def build_param_details
      result = []
      begin
        @job_class.new.method(:perform).parameters.each_with_index do |param, i|
          result << {
            name: param[1],
            named: param[0].to_s.include?('key'),
            required: param[0].to_s.include?('req'),
            position: i,
            type: nil
          }
        end
      rescue StandardError => e
        puts("ERROR: Unable to find method :perform for class #{job_class}: #{e.message}")
      end

      result
    end
  end
end
