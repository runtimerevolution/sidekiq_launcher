# frozen_string_literal: true

class NoParamsJob
  include Sidekiq::Job

  def perform
    puts('No Params Job is running')
  end
end
