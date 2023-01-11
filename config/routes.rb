# frozen_string_literal: true

SidekiqLauncher::Engine.routes.draw do
  get '/', to: 'jobs#index', as: 'sidekiq_launcher_jobs', defaults: { group: 'RRTools' }
  post '/run', to: 'jobs#run', as: 'sidekiq_launcher_run', defaults: { group: 'RRTools' }
end
