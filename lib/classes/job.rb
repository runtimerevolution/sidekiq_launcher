# frozen_string_literal: true

module SidekiqLauncher
  # TODO:
  class Job
    # TODO: Enum with possible types? Or string array?

    attr_reader :job_class, :file_name, :parameters

    def initialize(job_class)
      @job_class = job_class
      @file_name = Class.const_source_location(job_class.to_s)[0]&.split('/')&.last || 'File not found'
      @parameters = build_param_details
    end

    private

    # Build the specification for the parameters of the perform method
    # of the sidekiq job class
    def build_param_details
      result = []
      @job_class.new.method(:perform).parameters.each_with_index do |param, i|
        result << {
          name: param[1],
          named: param[0].to_s.include?('key'),
          required: param[0].to_s.include?('req'),
          position: i
        }
      end
      result
    end
  end
end
