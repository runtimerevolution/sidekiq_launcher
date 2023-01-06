# frozen_string_literal: true

module TestModule
  class HardJob
    include Sidekiq::Job

    def perform(name, count, stuff)
      puts("Hard Job is running with params: name #{name}, count #{count} and stuff #{stuff}")
    end
  end
end
