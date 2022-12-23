# frozen_string_literal: true

require 'test_helper'

module SidekiqLauncher
  class JobsControllerTest < ActionDispatch::IntegrationTest
    include Engine.routes.url_helpers

    test 'should get index' do
      get job_index_url
      assert_response :success
    end
  end
end
