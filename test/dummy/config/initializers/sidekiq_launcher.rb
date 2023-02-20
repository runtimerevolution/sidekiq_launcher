# frozen_string_literal: true

SidekiqLauncher.configure do |config|
  config.job_paths = [Rails.root.join('app', 'sidekiq_jobs'),
                      Rails.root.join('app', 'sidekiq_jobs', 'module_b'),
                      Rails.root.join('app', 'sidekiq_jobs', 'module_c'),
                      Rails.root.join('app', 'sidekiq_jobs', 'rbs_jobs'),
                      Rails.root.join('app', 'sidekiq_jobs', 'yard_jobs')]
end
