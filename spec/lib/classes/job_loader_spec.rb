# frozen_string_literal: true

require 'spec_helper'
require 'classes/job_loader'

RSpec.describe SidekiqLauncher::JobLoader do
  let(:valid_jobs) do
    [
      LotsOfArgsJob, YardJobs::TypesJob, RbsJobs::TypesJob,
      YardJobs::ComplexTypesJob, RbsJobs::ComplexTypesJob,
      ModuleC::HomonymousJob, ModuleB::HomonymousJob,
      HomonymousJob, NoParamsJob
    ]
  end

  let(:invalid_jobs) do
    [
      ComplexParamsJob, DefaultParamsJob, MisconfiguredJob,
      MultipleParamTypesJob, NamedParamsJob
    ]
  end

  before do
    described_class.reload_jobs
  end

  it 'only loads valid jobs' do
    expect(described_class.jobs.collect(&:job_class)).to(include(*valid_jobs))
    expect(described_class.jobs.collect(&:job_class)).not_to(include(*invalid_jobs))
  end

  it 'loads job properties' do
    expect(described_class.job_by_name('HomonymousJob')).not_to(be_nil)
  end

  it 'ignores loading properties from non existing job' do
    expect(described_class.job_by_name('NonExistingJob')).to(be_nil)
  end
end
