# frozen_string_literal: true

class ComplexParamsJob
  include Sidekiq::Job

  def perform(some_array, some_hash: { default_hash_val: 'val' })
    puts("Complex Params Job is running with params: some_array #{some_array} and some_hash #{some_hash}")
  end
end
