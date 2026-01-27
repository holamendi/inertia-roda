require_relative "test_helper"

class InertiaRedirectTest < InertiaTest
  def app
    Class.new(Roda) do
      plugin :inertia

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
