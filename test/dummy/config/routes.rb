# frozen_string_literal: true

Rails.application.routes.draw do
  mount SidekiqLauncher::Engine => '/sidekiq_launcher'
end
