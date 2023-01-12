# frozen_string_literal: true

require_relative 'lib/sidekiq_launcher/version'

Gem::Specification.new do |spec|
  spec.name        = 'sidekiq_launcher'
  spec.version     = SidekiqLauncher::VERSION
  spec.authors     = ['Luís Henriques']
  spec.email       = ['l.henriques@runtime-revolution.com']
  spec.homepage    = 'https://github.com/runtimerevolution/sidekiq_launcher'
  spec.summary     = 'Summary of SidekiqLauncher.'
  spec.description = 'Description of SidekiqLauncher.'
  spec.license     = 'MIT'
  spec.required_ruby_version = '>= 3.0'

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the "allowed_push_host"
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  spec.metadata['allowed_push_host'] = "TODO: Set to 'http://mygemserver.com'"

  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri'] = 'https://github.com/runtimerevolution/sidekiq_launcher'
  spec.metadata['changelog_uri'] = 'https://github.com/runtimerevolution/sidekiq_launcher'

  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    Dir['{app,config,db,lib}/**/*', 'MIT-LICENSE', 'Rakefile', 'README.md']
  end

  spec.metadata['rubygems_mfa_required'] = 'true'

  spec.add_development_dependency 'byebug', '<= 11.1.3'
  spec.add_development_dependency 'puma', '<= 6.0.0'
  spec.add_development_dependency 'rails', '>= 7.0.2.2'
  spec.add_development_dependency 'rbs', '>= 2.8.3'
  spec.add_development_dependency 'rbs_rails', '>=0.11.0'
  spec.add_development_dependency 'rubocop', '<= 1.41.0'
  spec.add_development_dependency 'sidekiq', '<= 6.5.8'
  spec.add_development_dependency 'yard', '>= 0.9.28'

  spec.add_dependency 'dry-validation', '<= 1.10.0'
  spec.add_dependency 'rb_json5', '>= 0.3.0'
end
