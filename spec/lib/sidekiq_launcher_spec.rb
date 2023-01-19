# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SidekiqLauncher do
  describe 'Zeitwerk' do
    it 'eager loads all files' do
      expect { Zeitwerk::Loader.eager_load_all }.not_to raise_error
    end
  end
end
