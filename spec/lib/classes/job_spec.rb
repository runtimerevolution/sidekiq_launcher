# frozen_string_literal: true

require 'spec_helper'
require 'classes/job'

# rubocop:disable Metrics/BlockLength
RSpec.describe SidekiqLauncher::Job do
  let(:allowed_param_types) { %i[string integer number boolean array hash] }
  let(:simple_job) { described_class.new(HomonymousJob) }

  it 'check legal param types' do
    expect(described_class.list_arg_types).to eq(allowed_param_types)
  end

  context 'when retrieving parameter details' do
    it 'retrieves all details' do
      expect(simple_job.param_specs('count')).to(
        eq({ allowed_types: allowed_param_types, name: 'count', position: 1, required: true })
      )
    end

    it 'ignores requested details for non existing parameter' do
      expect(simple_job.param_specs('non_existing_param')).to(be_nil)
    end
  end

  context 'with any job' do
    it 'instantiates the job with essential data elements' do
      expect(simple_job.job_class).not_to(be_nil)
      expect(simple_job.file_path).not_to(be_nil)
      expect(simple_job.parameters).not_to(be_nil)
    end
  end

  context 'with a job without a param type reader' do
    let(:no_params_job) { described_class.new(NoParamsJob) }

    it 'instantiates the job with unspecified param types' do
      expect(simple_job.parameters).to(
        eq(
          [{ name: 'name', required: true, position: 0, allowed_types: allowed_param_types },
           { name: 'count', required: true, position: 1, allowed_types: allowed_param_types }]
        )
      )
    end

    it 'instantiates the job with no parameters' do
      expect(no_params_job.parameters).to(be_empty)
    end
  end

  context 'with a job with Yard type reader' do
    let(:yard_simple_job) { described_class.new(SidekiqYard::TypesJob) }
    let(:yard_complex_job) { described_class.new(SidekiqYard::ComplexTypesJob) }

    it 'instantiates a job with a single type for each parameter' do
      expect(yard_simple_job.parameters).to(
        eq(
          [{ name: 'name', required: true, position: 0, allowed_types: %i[string] },
           { name: 'count', required: true, position: 1, allowed_types: %i[integer] },
           { name: 'stuff', required: true, position: 2, allowed_types: %i[array] }]
        )
      )
    end

    it 'instantiates a job with multiple types for each parameter' do
      expect(yard_complex_job.parameters).to(
        eq(
          [{ name: 'name', required: true, position: 0, allowed_types: %i[hash string] },
           { name: 'count', required: true, position: 1, allowed_types: %i[integer number] },
           { name: 'stuff', required: true, position: 2, allowed_types: %i[array boolean] }]
        )
      )
    end
  end

  context 'with a job with RBS type reader' do
    let(:rbs_simple_job) { described_class.new(SidekiqRbs::TypesJob) }
    let(:rbs_complex_job) { described_class.new(SidekiqRbs::ComplexTypesJob) }

    it 'instantiates a job with a single type for each parameter' do
      expect(rbs_simple_job.parameters).to(
        eq(
          [{ name: 'name', required: true, position: 0, allowed_types: %i[string] },
           { name: 'count', required: true, position: 1, allowed_types: %i[number] },
           { name: 'stuff', required: true, position: 2, allowed_types: %i[array] }]
        )
      )
    end

    it 'instantiates a job with multiple types for each parameter' do
      expect(rbs_complex_job.parameters).to(
        eq(
          [{ name: 'number', required: true, position: 0, allowed_types: %i[integer number] },
           { name: 'count', required: true, position: 1, allowed_types: %i[number] },
           { name: 'stuff', required: true, position: 2, allowed_types: %i[array hash string] }]
        )
      )
    end
  end
end
# rubocop:enable Metrics/BlockLength
