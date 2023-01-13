# frozen_string_literal: true

require_relative 'i_param_type_adapter'
require 'classes/job'

module SidekiqLauncher
  module ParamTypeReaders
    # Default type reader simply allows all types to be associated with the passed params
    class DefaultAdapter < IParamTypeAdapter
      # This reader is always available as it is the default one
      #
      # @return [self] The default parameter type adapter
      def available?
        self
      end

      # Always returns the full list of possible types for the passed argument
      #
      # @param _param_name [String] The name of the parameter to be checked
      # @return [Array<Sym>] List full list of types that can be assigned to a parameter
      def allowed_types_for(_param_name)
        SidekiqLauncher::Job.list_arg_types
      end
    end
  end
end
