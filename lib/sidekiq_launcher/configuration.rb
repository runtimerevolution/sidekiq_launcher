# frozen_string_literal: true

require 'rails'

module SidekiqLauncher
  # This class encapsulates the configuration for the Sidekiq Launcher gem
  class Configuration
    attr_reader :job_paths, :rrtools_grouped_gems

    # Initializes the default configuration
    def initialize
      begin
        @rrtools_grouped_gems = Rails.application.routes.routes.select { |prop| prop.defaults[:group] == 'RRTools' }
                                     .collect do |route|
          {
            name: route.name,
            path: route.path.build_formatter.instance_variable_get('@parts').join
          }
        end || []
      rescue NoMethodError
        @rrtools_grouped_gems = []
      end

      begin
        @job_paths = [Rails.root.join('app', 'sidekiq')]
      rescue NoMethodError
        @job_paths = []
      end
    end

    # Validates and sets job paths in the configuration
    #
    # @param paths [Array<Pathname, String>, Pathname, String] Paths with Sidekiq job files
    # @return [Array<Pathname, String>] A list of validated paths
    def job_paths=(paths)
      validated_paths = []
      paths = [paths] unless paths.is_a?(Array)

      paths.each do |path|
        validated_paths << path if (path.is_a?(Pathname) || path.is_a?(String)) && File.directory?(path)
      end
      @job_paths = validated_paths
    end
  end
end
