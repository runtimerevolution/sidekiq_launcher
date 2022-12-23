module SidekiqLauncher
  class Engine < ::Rails::Engine
    isolate_namespace SidekiqLauncher
  end
end
