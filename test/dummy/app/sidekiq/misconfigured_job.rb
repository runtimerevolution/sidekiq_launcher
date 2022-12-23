# frozen_string_literal: true

class MisconfiguredJob
  include Sidekiq::Job

  def perform_badly_named(name, count)
    puts("Misconfigured Job is running with params: name #{name} and count #{count}")
  end
end
