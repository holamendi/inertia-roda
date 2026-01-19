# test/inertia_render_html_test.rb
require_relative "test_helper"
require "json"
require "cgi"

class InertiaRenderHtmlTest < InertiaTest
  TEST_ROOT = File.dirname(__FILE__)

  def app
    test_root = TEST_ROOT
    Class.new(Roda) do
      opts[:root] = test_root
      plugin :inertia, version: "1.0"

      route do |r|
        r.root do
          inertia "Home", props: {name: "World"}
        end
      end
    end
  end

  def test_returns_html_for_regular_request
    get "/"
    assert_includes last_response.content_type, "text/html"
  end

  def test_html_contains_app_div_with_page_data
    get "/"
    assert_includes last_response.body, '<div id="app" data-page='
  end

  def test_page_data_contains_component_and_props
    get "/"

    # Extract JSON from data-page attribute (now using double quotes and HTML-escaped)
    match = last_response.body.match(/data-page="([^"]+)"/)
    assert match, "Could not find data-page attribute"

    # Unescape HTML entities before parsing JSON
    json_str = CGI.unescapeHTML(match[1])
    data = JSON.parse(json_str)
    assert_equal "Home", data["component"]
    assert_equal({"name" => "World"}, data["props"])
  end
end

class InertiaXssPreventionTest < InertiaTest
  TEST_ROOT = File.dirname(__FILE__)

  def app
    test_root = TEST_ROOT
    Class.new(Roda) do
      opts[:root] = test_root
      plugin :inertia, version: "1.0"

      route do |r|
        r.get "xss" do
          inertia "Test", props: {data: "test'><script>alert(1)</script>"}
        end

        r.get "xss-double-quote" do
          inertia "Test", props: {data: 'test"><script>alert(1)</script>'}
        end
      end
    end
  end

  def test_escapes_single_quotes_in_props
    get "/xss"

    # The script tag should be escaped, not executable
    refute_includes last_response.body, "<script>alert(1)</script>"
    # Should contain escaped version
    assert_includes last_response.body, "&lt;script&gt;"
  end

  def test_escapes_double_quotes_in_props
    get "/xss-double-quote"

    # The script tag should be escaped, not executable
    refute_includes last_response.body, "<script>alert(1)</script>"
    # Should contain escaped version
    assert_includes last_response.body, "&lt;script&gt;"
  end

  def test_data_is_recoverable_after_escaping
    get "/xss"

    # Extract and parse the data
    match = last_response.body.match(/data-page="([^"]+)"/)
    assert match, "Could not find data-page attribute"

    json_str = CGI.unescapeHTML(match[1])
    data = JSON.parse(json_str)

    # The original malicious string should be preserved as data (not executed)
    assert_equal "test'><script>alert(1)</script>", data["props"]["data"]
  end
end
