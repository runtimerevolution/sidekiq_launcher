# frozen_string_literal: true

require 'sidekiq'

class NamedParamsJob
  include Sidekiq::Job

  def perform(name:, count:)
    puts("Named Params Job is running with params: name #{name} and count #{count}")
  end
end
