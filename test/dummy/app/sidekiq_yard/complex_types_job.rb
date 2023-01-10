# frozen_string_literal: true

module SidekiqYard
  class ComplexTypesJob
    include Sidekiq::Job

    def perform(number, count, stuff)
      puts("Complex Types Job is running with params: number #{number}, count #{count} and stuff #{stuff}")
    end
  end
end
