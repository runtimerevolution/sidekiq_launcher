# frozen_string_literal: true

module SidekiqLauncher
  class Engine < ::Rails::Engine
    isolate_namespace SidekiqLauncher
  end
end
