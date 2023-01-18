# frozen_string_literal: true

class HomeController < ApplicationController
  def index
    redirect_to '/sidekiq_launcher'
  end
end
