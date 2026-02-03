require_relative "test_helper"
require "json"

class InertiaRenderJsonTest < InertiaTest
  def app
    Class.new(Roda) do
      plugin :inertia, version: "1.0"

      route do |r|
        r.root do
          inertia "Home", props: {name: "World"}
        end
      end
    end
  end

  def test_returns_json_for_inertia_request
    header "X-Inertia", "true"
    get "/"

    assert_equal "application/json", last_response.content_type
    assert_equal "true", last_response["X-Inertia"]
  end

  def test_json_contains_component_and_props
    header "X-Inertia", "true"
    get "/"
    data = JSON.parse(last_response.body)

    assert_equal "Home", data["component"]
    assert_equal({"name" => "World"}, data["props"])
  end

  def test_json_contains_url_and_version
    header "X-Inertia", "true"
    get "http://example.org/"
    data = JSON.parse(last_response.body)

    assert_equal "http://example.org/", data["url"]
    assert_equal "1.0", data["version"]
  end
end
