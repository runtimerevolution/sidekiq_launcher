# frozen_string_literal: true

require 'sidekiq_launcher/version'
require 'sidekiq_launcher/engine'
require 'sidekiq_launcher/configuration'

# Encapsulates all elements from Sidekiq Launcher
module SidekiqLauncher
  class << self
    # Users are able to both read and write their configuaration options
    attr_writer :configuration
  end

  # Returns the current configuration
  def self.configuration
    @configuration ||= Configuration.new
  end

  # Resets the current configuration for one with default values
  def self.reset
    @configuration = Configuration.new
  end

  def self.configure
    yield(configuration)
  end
end
