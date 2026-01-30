# test/inertia_root_test.rb
require_relative "test_helper"
require "json"
require "cgi"

class InertiaRootTest < InertiaTest
  def app
    views_path = File.join(__dir__, "views")
    Class.new(Roda) do
      plugin :inertia, version: "1.0"
      plugin :render, views: views_path

      route do |r|
        r.root do
          inertia "Home", props: {name: "World"}
        end
      end
    end
  end

  def test_inertia_root_renders_div_with_default_id
    get "/"

    assert_includes last_response.body, '<div id="app" data-page='
  end

  def test_inertia_root_escapes_page_data
    get "/"

    match = last_response.body.match(/data-page="([^"]+)"/)

    assert match, "Could not find data-page attribute"

    json_str = CGI.unescapeHTML(match[1])
    data = JSON.parse(json_str)

    assert_equal "Home", data["component"]
    assert_equal({"name" => "World"}, data["props"])
  end
end

class InertiaRootCustomIdTest < InertiaTest
  def app
    views_path = File.join(__dir__, "views")
    Class.new(Roda) do
      plugin :inertia, version: "1.0"
      plugin :render, views: views_path

      def inertia_root(id: "app")
        super(id: "custom-root")
      end

      route do |r|
        r.root do
          inertia "Home", props: {name: "World"}
        end
      end
    end
  end

  def test_inertia_root_accepts_custom_id
    get "/"

    assert_includes last_response.body, '<div id="custom-root" data-page='
  end
end
