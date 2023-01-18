# frozen_string_literal: true

require 'spec_helper'
require 'classes/param_type_readers/default_adapter'

RSpec.describe SidekiqLauncher::ParamTypeReaders::DefaultAdapter do
  let(:default_types_list) { %i[string integer number boolean array hash] }
  let(:subject) { described_class.new }

  it 'is always available' do
    expect(subject.available?).to(be(subject))
  end

  it 'it always returns the default parameter types' do
    expect(subject.allowed_types_for('some_param')).to(eq(default_types_list))
  end
end
