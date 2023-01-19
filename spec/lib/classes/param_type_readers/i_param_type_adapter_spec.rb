# frozen_string_literal: true

require 'spec_helper'
require 'classes/param_type_readers/i_param_type_adapter'

RSpec.describe SidekiqLauncher::ParamTypeReaders::IParamTypeAdapter do
  it 'does not implement available? method' do
    expect { described_class.new.available? }.to(raise_error)
  end

  it 'does not implement allowed_types_for() method' do
    expect { described_class.new.allowed_types_for('some_param') }.to(raise_error)
  end
end
