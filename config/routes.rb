# frozen_string_literal: true

SidekiqLauncher::Engine.routes.draw do
  get '/', to: 'jobs#index', as: 'sidekiq_launcher_jobs'
  post '/run', to: 'jobs#run', as: 'sidekiq_launcher_run'
end
