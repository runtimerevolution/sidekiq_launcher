# frozen_string_literal: true

require 'spec_helper'
require 'sidekiq_launcher/configuration'

RSpec.describe SidekiqLauncher::Configuration do
  let(:base_path) { "#{File.dirname(__FILE__)}/../.." }
  let(:valid_paths) { ["#{base_path}/lib/classes", "#{base_path}/lib/sidekiq_launcher"] }
  let(:invalid_paths) { ["#{base_path}/invalid_path", "#{base_path}/another/invalid/path"] }
  let(:multiple_paths) { valid_paths + invalid_paths }

  context 'with single valid path' do
    before do
      subject.job_paths = valid_paths.first
    end

    it 'accepts the path' do
      expect(subject.job_paths.count).to(be(1))
      expect(subject.job_paths.first).to(eq(valid_paths.first))
    end
  end

  context 'with multiple valid paths' do
    before do
      subject.job_paths = valid_paths
    end

    it 'accepts all paths' do
      expect(subject.job_paths.count).to(be(valid_paths.count))
      expect(subject.job_paths).to(eq(valid_paths))
    end
  end

  context 'with single invalid path' do
    before do
      subject.job_paths = invalid_paths.first
    end

    it 'rejects the path' do
      expect(subject.job_paths.count).to(be(0))
    end
  end

  context 'with multiple invalid paths' do
    before do
      subject.job_paths = invalid_paths
    end

    it 'rejects all paths' do
      expect(subject.job_paths.count).to(be(0))
    end
  end

  context 'with multiple valid and invalid paths' do
    before do
      subject.job_paths = multiple_paths
    end

    it 'filters valid paths' do
      expect(subject.job_paths.count).to(be(valid_paths.count))
      expect(subject.job_paths).to(eq(valid_paths))
    end
  end
end
