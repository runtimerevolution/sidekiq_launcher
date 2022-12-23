# frozen_string_literal: true

module SidekiqLauncher
  # This class encapsulates the configuration for the Sidekiq Launcher gem
  class Configuration
    attr_accessor :jobs_path

    def initialize
      @jobs_path = Rails.root.join('app', 'sidekiq')
    end
  end
end
