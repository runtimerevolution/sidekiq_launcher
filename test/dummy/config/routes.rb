# frozen_string_literal: true

require 'sidekiq/web'

Rails.application.routes.draw do
  mount SidekiqLauncher::Engine => '/sidekiq_launcher', defaults: { group: 'RRTools' }
  mount Sidekiq::Web => '/sidekiq' # mount Sidekiq::Web in app

  root 'home#index'
end
