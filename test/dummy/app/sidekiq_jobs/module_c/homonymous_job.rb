# frozen_string_literal: true

require 'sidekiq'

module ModuleC
  class HomonymousJob
    include Sidekiq::Job

    def perform(name, count, stuff)
      puts("Homonymous Job C is running with params: name #{name}, count #{count} and stuff #{stuff}")
    end
  end
end
