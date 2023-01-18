# frozen_string_literal: true

require 'rails_helper'
require 'action_controller'
require 'classes/job_loader'

# rubocop:disable Metrics/BlockLength
RSpec.describe SidekiqLauncher::JobsHelper, type: :helper do
  # rubocop:disable Naming/VariableNumber
  context 'when receiving user input' do
    let(:input_object) { ActionController::Parameters.new(user_input) }

    before do |test|
      SidekiqLauncher::JobLoader.reload_jobs if test.metadata[:load_jobs]
    end

    context 'with invalid parameters' do
      let(:user_input) { { job_class: 'HomonymousJob', unexpected: 'parameters', foo: 'bar' } }

      it 'ignores unexpected input' do
        expect(helper.send(:prep_params_input, input_object)).to(eq([]))
      end

      it 'does not run the sidekiq job', :load_jobs do
        expect(helper.run_job(input_object, run_job: false)[:success]).to(be(false))
      end
    end

    context 'with a set with incomplete parameters' do
      let(:user_input) do
        { job_class: 'HomonymousJob',
          arg_name_0: 'name_incomplete_arg', arg_value_0: 'value_incomplete_arg',
          arg_name_1: 'name_incomplete_arg_2', arg_type_1: 'string',
          arg_value_2: 'value_incomplete_arg', arg_type_2: 'string',
          arg_name_3: 'name', arg_value_3: 'foo', arg_type_3: 'string',
          arg_name_4: 'count', arg_value_4: '1', arg_type_4: 'integer' }
      end

      it 'ignores incomplete input entries' do
        expect(helper.send(:prep_params_input, input_object)).to(
          eq([
               { name: 'name', value: 'foo', type: :string },
               { name: 'count', value: '1', type: :integer }
             ])
        )
      end

      it 'runs the sidekiq job', :load_jobs do
        expect(helper.run_job(input_object, run_job: false)[:success]).to(be(true))
      end
    end

    context 'with a completely valid set of parameters' do
      let(:user_input) do
        { job_class: 'HomonymousJob',
          arg_name_0: 'name', arg_value_0: 'foo', arg_type_0: 'string',
          arg_name_1: 'count', arg_value_1: '1', arg_type_1: 'integer' }
      end

      it 'builds complete list of curated parameters' do
        expect(helper.send(:prep_params_input, input_object)).to(
          eq([
               { name: 'name', value: 'foo', type: :string },
               { name: 'count', value: '1', type: :integer }
             ])
        )
      end

      it 'runs the sidekiq job', :load_jobs do
        expect(helper.run_job(input_object, run_job: false)[:success]).to(be(true))
      end
    end
  end
  # rubocop:enable Naming/VariableNumber
end
# rubocop:enable Metrics/BlockLength
