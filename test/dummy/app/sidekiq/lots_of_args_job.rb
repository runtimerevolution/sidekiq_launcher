# frozen_string_literal: true

class LotsOfArgsJob
  include Sidekiq::Job

  def perform(name, count, weight, height, width, other)
    puts("Lots Of Args Job is running with params: name #{name}, count #{count}, weight #{weight}, height #{height}, width #{width}, other #{other}")
  end
end
