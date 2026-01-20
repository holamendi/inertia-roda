# test/inertia_request_test.rb
require_relative "test_helper"

class InertiaRequestTest < InertiaTest
  def app
    Class.new(Roda) do
      plugin :inertia

      route do |r|
        r.root do
          inertia_request? ? "inertia" : "regular"
        end
      end
    end
  end

  def test_returns_false_for_regular_requests
    get "/"

    assert_equal "regular", last_response.body
  end

  def test_returns_true_for_inertia_requests
    header "X-Inertia", "true"
    get "/"

    assert_equal "inertia", last_response.body
  end
end
