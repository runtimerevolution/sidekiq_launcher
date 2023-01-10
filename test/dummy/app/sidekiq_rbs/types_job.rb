# frozen_string_literal: true

module SidekiqRbs
  class TypesJob
    include Sidekiq::Job

    def perform(name, count, stuff)
      puts("Types Job is running with params: name #{name}, count #{count} and stuff #{stuff}")
    end
  end
end
