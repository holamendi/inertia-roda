# test/test_helper.rb
require 'minitest/autorun'
require 'rack/test'
require 'roda'
require_relative '../lib/inertia_roda'

class InertiaTest < Minitest::Test
  include Rack::Test::Methods
end
