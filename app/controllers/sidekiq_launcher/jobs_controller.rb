# frozen_string_literal: true

module SidekiqLauncher
  # Controller for running job views
  class JobsController < ApplicationController
    def index
      @sidekiq_installed = helpers.sidekiq_installed?
      return unless @sidekiq_installed

      @jobs = helpers.sidekiq_jobs
    end

    def run
      result = helpers.run_job(params)

      if result[:success]
        flash.notice = result[:messages]
      else
        flash.alert = result[:messages]
      end
      redirect_back(fallback_location: sidekiq_launcher_jobs_path)
    end
  end
end
