# frozen_string_literal: true

require 'sidekiq'

class NoParamsJob
  include Sidekiq::Job

  def perform
    puts('No Params Job is running')
  end
end
