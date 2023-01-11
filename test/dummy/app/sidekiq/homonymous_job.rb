# frozen_string_literal: true

class HomonymousJob
  include Sidekiq::Job

  def perform(name, count)
    puts("Homonymous Job A is running with params: name #{name} and count #{count}")
  end
end
