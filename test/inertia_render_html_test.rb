require_relative "test_helper"
require "json"
require "cgi"

class InertiaRenderHtmlTest < InertiaTest
  def app
    Class.new(Roda) do
      plugin :inertia, version: "1.0"

      route do |r|
        r.root do
          inertia "Home", props: {name: "Santiago"}
        end
      end
    end
  end

  def test_returns_html_for_regular_request
    get "/"

    assert_includes last_response.content_type, "text/html"
  end

  def test_page_data_contains_component_and_props
    get "/"

    match = last_response.body.match(/data-page="([^"]+)"/)

    assert match, "could not find data-page attribute"

    json = CGI.unescapeHTML(match[1])
    data = JSON.parse(json)

    assert_equal "Home", data["component"]
    assert_equal({"name" => "Santiago"}, data["props"])
  end
end

class InertiaXssPreventionTest < InertiaTest
  def app
    Class.new(Roda) do
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

    refute_includes last_response.body, "<script>alert(1)</script>"
    assert_includes last_response.body, "&lt;script&gt;"
  end

  def test_escapes_double_quotes_in_props
    get "/xss-double-quote"

    refute_includes last_response.body, "<script>alert(1)</script>"
    assert_includes last_response.body, "&lt;script&gt;"
  end

  def test_data_is_recoverable_after_escaping
    get "/xss"

    match = last_response.body.match(/data-page="([^"]+)"/)

    assert match, "Could not find data-page attribute"

    json = CGI.unescapeHTML(match[1])
    data = JSON.parse(json)

    assert_equal "test'><script>alert(1)</script>", data["props"]["data"]
  end
end
