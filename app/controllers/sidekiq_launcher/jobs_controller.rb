# frozen_string_literal: true

module SidekiqLauncher
  # Controller for running job views
  class JobsController < ApplicationController
    def index
      @sidekiq_installed = helpers.sidekiq_installed?
      return unless @sidekiq_installed

      @list_arg_types = helpers.arg_types
      @jobs = helpers.sidekiq_jobs
    end

    def run
      result = helpers.run_job(params)
      flash.alert = result[:messages]
      redirect_back(fallback_location: sidekiq_launcher_jobs_path)
    end
  end
end
