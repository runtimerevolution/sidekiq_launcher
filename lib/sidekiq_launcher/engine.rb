# frozen_string_literal: true

module SidekiqLauncher
  # This class starts the engine for the gem and all initializers
  #
  # When engine initializes it precompiles both css and js files
  class Engine < ::Rails::Engine
    isolate_namespace SidekiqLauncher

    config.generators do |g|
      g.test_framework :rspec
    end

    initializer :precompile do |app|
      app.config.assets.precompile << 'sidekiq_launcher/application.css'
    end
  end
end
