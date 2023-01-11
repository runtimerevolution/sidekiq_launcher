# frozen_string_literal: true

module SidekiqLauncher
  # This class encapsulates the configuration for the Sidekiq Launcher gem
  class Configuration
    attr_reader :job_paths

    def initialize
      @job_paths = [Rails.root.join('app', 'sidekiq')]
    end

    # Validates and assigns job paths
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
