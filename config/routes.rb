# frozen_string_literal: true

SidekiqLauncher::Engine.routes.draw do
  get 'jobs', to: 'jobs#index'
  post 'jobs/run', to: 'jobs#run'
end
