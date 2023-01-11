# frozen_string_literal: true

require_relative 'boot'

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)
require 'sidekiq_launcher'

module Dummy
  class Application < Rails::Application
    config.load_defaults Rails::VERSION::STRING.to_f

    # For compatibility with applications that use this config
    config.action_controller.include_all_helpers = false

    # Configuration for the application, engines, and railties goes here.
    #
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.
    #
    # config.time_zone = "Central Time (US & Canada)"
    # config.eager_load_paths << Rails.root.join("extras")
    SidekiqLauncher.configure do |config|
      config.job_paths = [Rails.root.join('app', 'sidekiq'),
                          Rails.root.join('app', 'sidekiq_module_b'),
                          Rails.root.join('app', 'sidekiq_module_c'),
                          Rails.root.join('app', 'sidekiq_rbs'),
                          Rails.root.join('app', 'sidekiq_yard')]
    end
  end
end
