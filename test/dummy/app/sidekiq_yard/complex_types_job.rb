# frozen_string_literal: true

module SidekiqYard
  class ComplexTypesJob
    include Sidekiq::Job

    # Performs a sample sidekiq job
    # @param name [String, Hash] the name
    # @param count [Integer, Number] the count
    # @param stuff [Array<String,  Number>, Boolean] the stuff
    def perform(name, count, stuff)
      puts("Complex Types Job is running with params: number #{name}, count #{count} and stuff #{stuff}")
    end
  end
end
