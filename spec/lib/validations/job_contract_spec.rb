# frozen_string_literal: true

require 'rails_helper'
require 'spec_helper'
require 'action_controller'
require 'validations/job_contract'
require 'classes/job_loader'

RSpec.describe SidekiqLauncher::JobContract do
  let(:input_object) { ActionController::Parameters.new(user_input) }

  let(:invalid_user_input_sets) do
    {
      wrong_params: [{ name: 'foo', value: 'bar', type: 'string' }, { name: 'baz', value: 'qux', type: 'string' }],
      incomplete_params: [{ name: 'name', value: 'foo', type: 'string' }],
      no_params: []
    }
  end

  let(:valid_user_input) do
    [
      { name: 'name', value: 'foo', type: 'string' },
      { name: 'count', value: '1', type: 'integer' }
    ]
  end

  before do
    SidekiqLauncher::JobLoader.reload_jobs
  end

  it 'does not validate invalid inputs' do
    invalid_user_input_sets.each do |input_set|
      expect(described_class.new.call(job_class: 'HomonymousJob', arguments: input_set).success?).to(be(false))
    end
  end

  it 'does not validate inputs for non existing jobs' do
    expect(described_class.new.call(job_class: 'NonExistingJob', arguments: valid_user_input).success?).to(be(false))
  end

  it 'validates valid inputs' do
    expect(described_class.new.call(job_class: 'HomonymousJob', arguments: valid_user_input).success?).to(be(true))
  end
end
