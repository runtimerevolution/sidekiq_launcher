# frozen_string_literal: true

module SidekiqLauncher
  # Application record
  class ApplicationRecord < ActiveRecord::Base
    self.abstract_class = true
  end
end
