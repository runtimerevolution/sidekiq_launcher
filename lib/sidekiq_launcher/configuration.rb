# frozen_string_literal: true

module SidekiqLauncher
  # This class encapsulates the configuration for the Sidekiq Launcher gem
  class Configuration
    attr_accessor :job_paths

    def initialize
      @job_paths = [Rails.root.join('app', 'sidekiq')]
    end
  end
end
