# frozen_string_literal: true

class DefaultParamsJob
  include Sidekiq::Job

  def perform(name: 'default_name', count: 1)
    puts("Default Params Job is running with params: name #{name} and count #{count}")
  end
end
