# frozen_string_literal: true

require 'spec_helper'
require 'classes/job'

require 'sidekiq'
require_relative '../../../test/dummy/app/sidekiq/lots_of_args_job'

RSpec.describe SidekiqLauncher::Job do
  let(:allowed_param_types) { %i[string integer number boolean array hash] }

  it 'check legal param types' do
    expect(described_class.list_arg_types).to eq(allowed_param_types)
  end
end
