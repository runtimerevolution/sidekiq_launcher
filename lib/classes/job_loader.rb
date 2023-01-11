# frozen_string_literal: true

require 'classes/job'

module SidekiqLauncher
  # It's the Job Loader's responsibility to load all valid Sidekiq Jobs in the current application
  class JobLoader
    class << self
      # List of sidekiq jobs and their specifications
      def jobs
        @jobs || load_jobs
      end

      # Reloads all sidekiq jobs
      def reload_jobs
        load_jobs
      end

      # Returns the properties of the job with the passed name as String
      def job_props(class_name)
        @jobs&.find { |j| j.job_class.to_s == class_name }
      end

      private

      # Loads all sidekiq jobs from the current application
      # Returns the list of jobs
      def load_jobs
        @jobs = []

        possible_jobs = Set[]
        possible_jobs.merge(load_job_classes_from_cache)
        possible_jobs.merge(load_classes_from_config_paths)

        possible_jobs.each do |pj|
          @jobs << Job.new(pj) if valid_job_class?(pj)
        end

        @jobs
      end

      # Loads sidekiq job classes from the cached classes
      def load_job_classes_from_cache
        ObjectSpace.each_object(Class).select { |child| child < Sidekiq::Worker::Options && child.include?(Sidekiq::Job) }
      end

      # Loads all classes from the configured paths
      def load_classes_from_config_paths
        result = []
        paths = SidekiqLauncher.configuration.job_paths
        paths = [paths] unless paths.is_a?(Array)

        paths.each do |path|
          next unless File.directory?(path)

          result.concat(load_classes_from_path(path))
        end
        result
      end

      # Loads all classes from a single dir
      def load_classes_from_path(path)
        result = []
        Dir.children(path).each do |file_name|
          file = path.to_s.concat("/#{file_name}")
          klass = class_name_from_file(file)

          begin
            # Loading class if not loaded
            require file unless Object.const_defined?(klass)
          rescue NameError
            nil
          end

          # If we enter the NameError exception, we still want to try to constantize the class
          begin
            result << klass.constantize unless klass == ''
          rescue NameError
            nil
          end
        end
        result
      end

      # Build a class name from a class file
      def class_name_from_file(file)
        klass = ''
        File.readlines(file).each do |line|
          klass = ("#{klass}#{line.split[1]}::" || '') if line.include?('module')
          next unless line.include?('class')

          klass = ("#{klass}#{line.split[1]}" || '')
          break
        end
        klass
      end

      # Checks if the passed class name reffers to a valid Sidekiq job
      def valid_job_class?(job_class)
        return false unless job_class < Sidekiq::Worker::Options
        return false unless job_class.include?(Sidekiq::Job)

        begin
          perform_method = job_class.new.method(:perform)

          # Jobs cannot have named methods
          perform_method.parameters.each do |param|
            return false if param[0].to_s.include?('key')
          end
        rescue NameError
          return false
        end
        true
      end
    end
  end
end