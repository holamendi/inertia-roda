# test/inertia_shared_data_test.rb
require_relative "test_helper"
require "json"

class InertiaSharedDataTest < InertiaTest
  def app
    @app || Class.new(Roda) do
      plugin :inertia, version: "1.0"

      def inertia_shared_data
        {shared_key: "shared_value"}
      end

      route do |r|
        r.root do
          inertia "Home", props: {local_key: "local_value"}
        end
      end
    end
  end

  def test_merges_shared_data_into_props
    header "X-Inertia", "true"
    get "/"

    data = JSON.parse(last_response.body)
    assert_equal "shared_value", data["props"]["shared_key"]
    assert_equal "local_value", data["props"]["local_key"]
  end

  def test_local_props_override_shared_data
    app_with_override = Class.new(Roda) do
      plugin :inertia

      def inertia_shared_data
        {key: "shared"}
      end

      route do |r|
        r.root do
          inertia "Home", props: {key: "local"}
        end
      end
    end

    @app = app_with_override
    header "X-Inertia", "true"
    get "/"

    data = JSON.parse(last_response.body)
    assert_equal "local", data["props"]["key"]
  end
end
