# frozen_string_literal: true

module SidekiqLauncher
  # Controller for running job views
  class JobsController < ApplicationController
    def index
      # TODO: Message if path not available
      # TODO: Message if sidekiq not installed (returns uninitialized constant)
      # TODO: Probably use exceptions

      @list_arg_types = helpers.arg_types
      @jobs = helpers.sidekiq_jobs
    end

    def run
      result = helpers.run_job(params)
      flash.alert = result[:messages]
      redirect_back(fallback_location: jobs_path)
    end
  end
end
