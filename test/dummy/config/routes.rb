# frozen_string_literal: true

require 'sidekiq/web'

Rails.application.routes.draw do
  mount SidekiqLauncher::Engine => '/sidekiq_launcher'
  mount Sidekiq::Web => '/sidekiq' # mount Sidekiq::Web in app
end
