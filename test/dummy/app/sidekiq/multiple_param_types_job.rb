# frozen_string_literal: true

class MultipleParamTypesJob
  include Sidekiq::Job

  def perform(name, count, named_arg:, named_def_arg: 1)
    puts("Multiple Param Types Job is running with params: name #{name}, count #{count}, " \
         "named_arg: #{named_arg}, named_def_arg: #{named_def_arg}")
  end
end
