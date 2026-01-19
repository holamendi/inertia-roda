# test/inertia_version_test.rb
require_relative 'test_helper'

class InertiaVersionTest < InertiaTest
  def app
    @app || Class.new(Roda) do
      plugin :inertia, version: '1.0'

      route do |r|
        r.root do
          inertia 'Home', props: {}
        end
      end
    end
  end

  def test_matching_version_returns_normal_response
    header 'X-Inertia', 'true'
    header 'X-Inertia-Version', '1.0'
    get '/'

    assert_equal 200, last_response.status
  end

  def test_stale_version_returns_409_with_location
    header 'X-Inertia', 'true'
    header 'X-Inertia-Version', '0.9'
    get 'http://example.org/'

    assert_equal 409, last_response.status
    assert_equal 'http://example.org/', last_response['X-Inertia-Location']
  end

  def test_no_client_version_returns_normal_response
    header 'X-Inertia', 'true'
    get '/'

    assert_equal 200, last_response.status
  end

  def test_callable_version
    app_with_callable = Class.new(Roda) do
      plugin :inertia, version: -> { '2.0' }

      route do |r|
        r.root do
          inertia 'Home', props: {}
        end
      end
    end

    @app = app_with_callable
    header 'X-Inertia', 'true'
    header 'X-Inertia-Version', '1.0'
    get 'http://example.org/'

    assert_equal 409, last_response.status
  end

  def test_post_with_stale_version_proceeds_normally
    app_with_post = Class.new(Roda) do
      plugin :inertia, version: '1.0'

      route do |r|
        r.post 'submit' do
          inertia 'Form/Success', props: { message: 'Submitted' }
        end
      end
    end

    @app = app_with_post
    header 'X-Inertia', 'true'
    header 'X-Inertia-Version', '0.9'
    post '/submit'

    assert_equal 200, last_response.status
  end
end
