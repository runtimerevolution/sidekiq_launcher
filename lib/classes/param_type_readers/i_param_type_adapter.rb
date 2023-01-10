# frozen_string_literal: true

module ParamTypeReaders
  # This interface declares the methods to be implemented by ParamTypeReader Adapters
  # Their responsibility is to allow the consultation of expected parameter types depending
  # on the used declaration system (RBS, Yard docs, etc...)
  class IParamTypeAdapter
    # Initialize the class with the parameters required to check the adapter's availiability
    def initialize(*params) end

    # Checks preconditions to know if the current adapter is available
    # for the current sidekiq job
    # Requirements for this check should be passed in the Adapter's constructor
    # Returns self or nil depending on if the Sidekiq Job meets the requirements for the adapter
    def available?
      raise 'To be implemented by subclass'
    end

    # Returns an array with the allowed types for the passed parameter
    # If unable to find any, should return the default list
    # from SidekiqLauncher::Job.list_arg_types
    def allowed_types_for(_param_name)
      raise 'To be implemented by subclass'
    end
  end
end