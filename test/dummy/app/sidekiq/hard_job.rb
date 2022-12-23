# frozen_string_literal: true

class HardJob
  include Sidekiq::Job

  def perform(name, count)
    puts("Hard Job is running with params: name #{name} and count #{count}")
  end
end
