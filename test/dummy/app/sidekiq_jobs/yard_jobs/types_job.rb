# frozen_string_literal: true

require 'sidekiq'

module YardJobs
  class TypesJob
    include Sidekiq::Job

    # Performs a sample sidekiq job
    # @param name [String] the name
    # @param count [Integer] the count
    # @param stuff [Array<String>] the stuff
    def perform(name, count, stuff)
      puts("Types Job is running with params: name #{name}, count #{count} and stuff #{stuff}")
    end
  end
end
