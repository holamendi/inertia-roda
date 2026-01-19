# test/inertia_render_html_test.rb
require_relative 'test_helper'
require 'json'

class InertiaRenderHtmlTest < InertiaTest
  TEST_ROOT = File.dirname(__FILE__)

  def app
    test_root = TEST_ROOT
    Class.new(Roda) do
      opts[:root] = test_root
      plugin :inertia, version: '1.0'

      route do |r|
        r.root do
          inertia 'Home', props: { name: 'World' }
        end
      end
    end
  end

  def test_returns_html_for_regular_request
    get '/'
    assert_includes last_response.content_type, 'text/html'
  end

  def test_html_contains_app_div_with_page_data
    get '/'
    assert_includes last_response.body, '<div id="app" data-page='
  end

  def test_page_data_contains_component_and_props
    get '/'

    # Extract JSON from data-page attribute
    match = last_response.body.match(/data-page='([^']+)'/)
    assert match, "Could not find data-page attribute"

    data = JSON.parse(match[1])
    assert_equal 'Home', data['component']
    assert_equal({ 'name' => 'World' }, data['props'])
  end
end
