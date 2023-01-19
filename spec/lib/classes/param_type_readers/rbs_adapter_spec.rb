# frozen_string_literal: true

require 'spec_helper'
require 'classes/param_type_readers/rbs_adapter'
require 'classes/job'

RSpec.describe SidekiqLauncher::ParamTypeReaders::RbsAdapter do
  let(:adapter) { described_class.new(job.file_path) }
  let(:default_types_list) { %i[string integer number boolean array hash] }

  context 'with a simple job' do
    let(:job) { SidekiqLauncher::Job.new(RbsJobs::TypesJob) }

    it 'is available' do
      expect(adapter.available?).to(be(adapter))
    end

    it 'retrieves valid types for all parameters' do
      expect(adapter.allowed_types_for('name')).to(eq(%i[string]))
      expect(adapter.allowed_types_for('count')).to(eq(%i[number]))
      expect(adapter.allowed_types_for('stuff')).to(eq(%i[array]))
    end

    it 'retrieves default list of types by default' do
      expect(adapter.allowed_types_for('unknown_param')).to(eq(default_types_list))
    end
  end

  context 'with a job with complex parameters' do
    let(:job) { SidekiqLauncher::Job.new(RbsJobs::ComplexTypesJob) }

    it 'is available' do
      expect(adapter.available?).to(be(adapter))
    end

    it 'retrieves valid types for all parameters' do
      expect(adapter.allowed_types_for('number')).to(eq(%i[integer number]))
      expect(adapter.allowed_types_for('count')).to(eq(%i[number]))
      expect(adapter.allowed_types_for('stuff')).to(eq(%i[array hash string]))
    end
  end

  context 'with a job that does not support the current adapter' do
    let(:job) { SidekiqLauncher::Job.new(HomonymousJob) }

    it 'is not available' do
      expect(adapter.available?).to(be_nil)
    end

    it 'retrieves default list even if not available' do
      expect(adapter.allowed_types_for('some_param')).to(eq(default_types_list))
    end
  end
end
