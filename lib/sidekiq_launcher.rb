# frozen_string_literal: true

require 'rails'
require 'sidekiq_launcher/version'
require 'sidekiq_launcher/engine'
require 'sidekiq_launcher/configuration'

# Sidekiq Launcher base class to allow access to the configuration as well
# as provide functions to ensure the gem's requirements are met
module SidekiqLauncher
  class << self
    # Users are able to both read and write their configuaration options
    attr_writer :configuration

    # Checks if the Sidekiq gem is installed
    #
    # @return [Boolean] True if Sidekiq gem is installed
    def sidekiq_installed?
      Object.const_defined?('Sidekiq')
    end

    # Returns the current configuration
    #
    # @return [Configuration] The current configuration object
    def configuration
      @configuration ||= Configuration.new
    end

    # Resets the current configuration for one with default values
    #
    # @return [Configuration] The current configuration object
    def reset_config
      @configuration = Configuration.new
    end

    def configure
      yield(configuration)
    end
  end
end
