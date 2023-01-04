# frozen_string_literal: true

require 'sidekiq_launcher/version'
require 'sidekiq_launcher/engine'
require 'sidekiq_launcher/configuration'
require 'classes/job'

# Encapsulates all elements from Sidekiq Launcher
module SidekiqLauncher
  class << self
    # Users are able to both read and write their configuaration options
    attr_writer :configuration

    # List of sidekiq jobs and their specifications
    def jobs
      @jobs || load_jobs
    end

    # Reloads all sidekiq jobs
    def reload_jobs
      load_jobs
    end

    # Returns the current configuration
    def configuration
      @configuration ||= Configuration.new
    end

    # Resets the current configuration for one with default values
    def reset_config
      @configuration = Configuration.new
    end

    def configure
      yield(configuration)
    end

    private

    # Loads all sidekiq jobs from the current application
    # Returns the list of jobs
    def load_jobs
      @jobs = []

      possible_jobs = []
      possible_jobs.concat(load_job_classes_from_cache)
      possible_jobs.concat(load_job_classes_from_dirs)

      possible_jobs.each do |pj|
        @jobs << Job.new(pj) if valid_job_class?(pj)
      end

      @jobs
    end

    # Loads sidekiq job classes from the cached classes
    def load_job_classes_from_cache
      ObjectSpace.each_object(Class).select { |child| child < Sidekiq::Worker::Options && child.include?(Sidekiq::Job) }
    end

    # Loads sidekiq job classes from the configured paths
    def load_job_classes_from_dirs
      result = []
      job_files = []
      paths = SidekiqLauncher.configuration.job_paths

      if paths.is_a?(Array)
        paths.each do |path|
          job_files.concat(Dir.children(path))
        end
      else
        job_files.concat(Dir.children(paths))
      end

      job_files.each do |jf|
        result << jf.delete_suffix('.rb').classify.constantize
      end
      result
    end

    # Checks if the passed class name reffers to a valid Sidekiq job
    def valid_job_class?(job_class)
      # TODO: Check if descends from class?

      begin
        job_class.new.method(:perform)
      rescue NameError
        return false
      end
      true
    end
  end
end
