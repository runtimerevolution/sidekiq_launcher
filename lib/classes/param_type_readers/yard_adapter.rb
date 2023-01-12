# frozen_string_literal: true

require_relative 'i_param_type_adapter'
require 'classes/job'

module ParamTypeReaders
  # Checks expected parameter types for the passed job, declared in the matching Yard doc
  class YardAdapter < IParamTypeAdapter
    def initialize(file_path)
      super
      file = "#{Rails.root}#{file_path}"
      return unless File.exist?(file)

      @param_types = read_param_types(file)
    end

    # Checks if the current job is available to use the Yard adapter
    #
    # @return [self, nil] Returns self or nil depending on if the Sidekiq Job meets the requirements for the adapter
    def available?
      @param_types&.count&.positive? ? self : nil
    end

    # Returns an array with the allowed types for the passed parameter
    # If unable to find any, should return the default list
    # from SidekiqLauncher::Job.list_arg_types
    #
    # @param _param_name [String] The name of the parameter to be checked
    # @return [Array<Sym>] List of specified types for the passed parameter
    def allowed_types_for(param_name)
      @param_types[param_name] || SidekiqLauncher::Job.list_arg_types
    end

    private

    # Builds the list of parameter types from the Yard docs of the :perform function
    #
    # @param file [String] The full path of the Sidekiq job class file
    # @return [Hash { String: Array<Sym> }] A map containing type specifications for every parameter
    def read_param_types(file)
      result = {}
      reading = false

      File.readlines(file).reverse.each do |line|
        if line.include?('def perform')
          reading = true
          next
        end

        if reading
          if line.include?('@param')
            param_name = read_param_name(line)
            types_line = read_types(line)

            types = build_types_from_line(types_line)
            result[param_name] = types

          # Once we reach the end of the doc block (we are reading from bottom to top)
          elsif line == "\n"
            break
          end
        end
      end

      result
    end

    # Interprets the param name from the passed line
    def read_param_name(line)
      line.match(/@param .*? /).to_s.split&.second || ''
    end

    # Interprets the declared variable types from the passed line
    def read_types(line)
      # Retrieving types specification and clearing array and hash types
      line.match(/\[.*?\]/).to_s.gsub(/<.*?>/, '').gsub(/{.*?}/, '')
    end

    # Builds an array of types from a line describing allowed types for the parameter
    def build_types_from_line(line)
      result = []
      result << :array if line.include?('Array')
      result << :integer if line.include?('Integer')
      result << :number if line.include?('Number')
      result << :boolean if line.include?('Boolean')
      result << :hash if line.include?('Hash')
      result << :string if line.include?('String')
      result
    end
  end
end
