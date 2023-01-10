# frozen_string_literal: true

require_relative 'i_param_type_adapter'

module ParamTypeReaders
  # Checks expected parameter types for the passed job, declared in the matching Swagger doc
  class SwaggerAdapter < IParamTypeAdapter
    def initialize(file_path)
      super

    end

    def available?
      nil
    end

    def allowed_types_for(param_name)

    end

  end
end
