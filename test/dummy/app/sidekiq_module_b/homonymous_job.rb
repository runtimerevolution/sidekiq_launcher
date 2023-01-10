# frozen_string_literal: true

module SidekiqModuleB
  class HomonymousJob
    include Sidekiq::Job

    def perform(name, count, stuff)
      puts("Homonymous Job B is running with params: name #{name}, count #{count} and stuff #{stuff}")
    end
  end
end
