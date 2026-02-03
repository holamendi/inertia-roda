require_relative "test_helper"

class InertiaRedirectTest < InertiaTest
  def app
    views_path = File.join(__dir__, "views")
    Class.new(Roda) do
      plugin :inertia
      plugin :render, views: views_path

      route do |r|
        r.post "submit" do
          inertia_redirect "/destination"
        end

        r.get "redirect" do
          inertia_redirect "/destination"
        end

        r.get "external" do
          inertia_redirect "https://example.com/path"
        end
      end
    end
  end

  def test_regular_redirect_uses_302
    get "/redirect"

    assert_equal 302, last_response.status
    assert_equal "/destination", last_response["Location"]
  end

  def test_inertia_get_redirect_uses_302
    header "X-Inertia", "true"
    get "/redirect"

    assert_equal 302, last_response.status
  end

  def test_inertia_post_redirect_uses_303
    header "X-Inertia", "true"
    post "/submit"

    assert_equal 303, last_response.status
    assert_equal "/destination", last_response["Location"]
  end

  def test_external_redirect_uses_409_with_location_header
    header "X-Inertia", "true"
    get "/external"

    assert_equal 409, last_response.status
    assert_equal "https://example.com/path", last_response["X-Inertia-Location"]
  end

  def test_external_redirect_regular_request_uses_302
    get "/external"

    assert_equal 302, last_response.status
    assert_equal "https://example.com/path", last_response["Location"]
  end
end

class InertiaRedirectCustomStatusTest < InertiaTest
  def app
    views_path = File.join(__dir__, "views")
    Class.new(Roda) do
      plugin :inertia
      plugin :render, views: views_path

      route do |r|
        r.get "redirect" do
          inertia_redirect "/destination", status: 301
        end

        r.post "submit" do
          inertia_redirect "/destination", status: 307
        end
      end
    end
  end

  def test_custom_status_on_regular_request
    get "/redirect"

    assert_equal 301, last_response.status
    assert_equal "/destination", last_response["Location"]
  end

  def test_custom_status_overrides_default_on_inertia_post
    header "X-Inertia", "true"
    post "/submit"

    assert_equal 307, last_response.status
    assert_equal "/destination", last_response["Location"]
  end
end

class InertiaRedirectSameHostTest < InertiaTest
  def app
    views_path = File.join(__dir__, "views")
    Class.new(Roda) do
      plugin :inertia
      plugin :render, views: views_path

      route do |r|
        r.get "same-host" do
          inertia_redirect "http://example.org/same-host-path"
        end
      end
    end
  end

  def test_same_host_absolute_url_redirects_normally
    header "X-Inertia", "true"
    get "/same-host"

    assert_equal 302, last_response.status
    assert_equal "http://example.org/same-host-path", last_response["Location"]
  end
end
