# frozen_string_literal: true

require_relative 'i_param_type_adapter'

module ParamTypeReaders
  # Checks expected parameter types for the passed job, declared in the matching Yard doc
  class YardAdapter < IParamTypeAdapter
    def initialize(file_path)
      super
      @file_path = file_path
    end

    def available?


      # TODO: build dictionary

      nil
    end

    def allowed_types_for(param_name)

    end
  end
end
