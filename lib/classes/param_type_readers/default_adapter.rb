# frozen_string_literal: true

require_relative 'i_param_type_adapter'
require 'classes/job'

module ParamTypeReaders
  # Default type reader simply allows all types to be associated with the passed params
  class DefaultAdapter < IParamTypeAdapter
    # This reader is always available as it is the default one
    def available?
      self
    end

    # Always returns the full list of possible types for the passed argument
    def allowed_types_for(_param_name)
      SidekiqLauncher::Job.list_arg_types
    end
  end
end
