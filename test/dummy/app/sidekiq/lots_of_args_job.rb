# frozen_string_literal: true

class LotsOfArgsJob
  include Sidekiq::Job

  # rubocop:disable Metrics/ParameterLists
  def perform(name, count, weight, height, width, other)
    puts("Lots Of Args Job is running with params: name #{name}, count #{count}, weight #{weight}, " \
         "height #{height}, width #{width}, other #{other}")
  end
  # rubocop:enable Metrics/ParameterLists
end
