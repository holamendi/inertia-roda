# inertia-roda Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Build a Roda plugin providing Inertia.js server-side adapter with rendering, shared data, redirects, and asset versioning.

**Architecture:** Single Roda plugin (`plugin :inertia`) that auto-loads the render plugin and provides instance methods for Inertia responses. Uses ERB templates for HTML shell, returns JSON for XHR requests.

**Tech Stack:** Ruby, Roda, Minitest, Rack::Test

---

### Task 1: Gem Structure

**Files:**
- Create: `inertia-roda.gemspec`
- Create: `lib/inertia_roda.rb`
- Create: `lib/roda/plugins/inertia.rb`
- Create: `Gemfile`
- Create: `Rakefile`

**Step 1: Create gemspec**

```ruby
# inertia-roda.gemspec
Gem::Specification.new do |s|
  s.name        = 'inertia-roda'
  s.version     = '0.1.0'
  s.summary     = 'Inertia.js adapter for Roda'
  s.description = 'A Roda plugin providing server-side Inertia.js adapter'
  s.authors     = ['Pablo']
  s.files       = Dir['lib/**/*.rb']
  s.homepage    = 'https://github.com/pablo/inertia-roda'
  s.license     = 'MIT'

  s.required_ruby_version = '>= 2.7.0'

  s.add_dependency 'roda', '>= 3.0'

  s.add_development_dependency 'minitest', '~> 5.0'
  s.add_development_dependency 'rack-test', '~> 2.0'
  s.add_development_dependency 'rake', '~> 13.0'
  s.add_development_dependency 'tilt', '~> 2.0'
end
```

**Step 2: Create gem entry point**

```ruby
# lib/inertia_roda.rb
require_relative 'roda/plugins/inertia'
```

**Step 3: Create plugin skeleton**

```ruby
# lib/roda/plugins/inertia.rb
require 'json'

class Roda
  module RodaPlugins
    module Inertia
      def self.load_dependencies(app, opts = {})
        app.plugin :render
      end

      def self.configure(app, opts = {})
        app.opts[:inertia_version] = opts[:version]
        app.opts[:inertia_template] = opts[:template] || 'inertia'
      end

      module InstanceMethods
        def inertia_request?
          request.get_header('HTTP_X_INERTIA') == 'true'
        end
      end
    end

    register_plugin(:inertia, Inertia)
  end
end
```

**Step 4: Create Gemfile**

```ruby
# Gemfile
source 'https://rubygems.org'

gemspec
```

**Step 5: Create Rakefile**

```ruby
# Rakefile
require 'rake/testtask'

Rake::TestTask.new(:test) do |t|
  t.libs << 'test'
  t.libs << 'lib'
  t.test_files = FileList['test/**/*_test.rb']
end

task default: :test
```

**Step 6: Commit**

```bash
git add -A
git commit -m "feat: initialize gem structure with plugin skeleton"
```

---

### Task 2: Test Helper and First Test

**Files:**
- Create: `test/test_helper.rb`
- Create: `test/inertia_request_test.rb`

**Step 1: Create test helper**

```ruby
# test/test_helper.rb
require 'minitest/autorun'
require 'rack/test'
require 'roda'
require_relative '../lib/inertia_roda'

class InertiaTest < Minitest::Test
  include Rack::Test::Methods
end
```

**Step 2: Write failing test for inertia_request?**

```ruby
# test/inertia_request_test.rb
require_relative 'test_helper'

class InertiaRequestTest < InertiaTest
  def app
    Class.new(Roda) do
      plugin :inertia

      route do |r|
        r.root do
          inertia_request? ? 'inertia' : 'regular'
        end
      end
    end
  end

  def test_returns_false_for_regular_requests
    get '/'
    assert_equal 'regular', last_response.body
  end

  def test_returns_true_for_inertia_requests
    header 'X-Inertia', 'true'
    get '/'
    assert_equal 'inertia', last_response.body
  end
end
```

**Step 3: Run tests to verify they pass**

Run: `bundle install && bundle exec rake test`
Expected: 2 tests, 0 failures

**Step 4: Commit**

```bash
git add -A
git commit -m "test: add inertia_request? detection tests"
```

---

### Task 3: JSON Rendering for Inertia Requests

**Files:**
- Create: `test/inertia_render_json_test.rb`
- Modify: `lib/roda/plugins/inertia.rb`

**Step 1: Write failing test for JSON rendering**

```ruby
# test/inertia_render_json_test.rb
require_relative 'test_helper'
require 'json'

class InertiaRenderJsonTest < InertiaTest
  def app
    Class.new(Roda) do
      plugin :inertia, version: '1.0'

      route do |r|
        r.root do
          inertia 'Home', props: { name: 'World' }
        end
      end
    end
  end

  def test_returns_json_for_inertia_request
    header 'X-Inertia', 'true'
    get '/'

    assert_equal 'application/json', last_response.content_type
    assert_equal 'true', last_response['X-Inertia']
  end

  def test_json_contains_component_and_props
    header 'X-Inertia', 'true'
    get '/'

    data = JSON.parse(last_response.body)
    assert_equal 'Home', data['component']
    assert_equal({ 'name' => 'World' }, data['props'])
  end

  def test_json_contains_url_and_version
    header 'X-Inertia', 'true'
    get 'http://example.org/'

    data = JSON.parse(last_response.body)
    assert_equal 'http://example.org/', data['url']
    assert_equal '1.0', data['version']
  end
end
```

**Step 2: Run test to verify it fails**

Run: `bundle exec rake test`
Expected: FAIL with "undefined method `inertia'"

**Step 3: Implement inertia method for JSON rendering**

Update `lib/roda/plugins/inertia.rb`, add to InstanceMethods:

```ruby
def inertia(component, props: {})
  page_data = {
    component: component,
    props: inertia_shared_data.merge(props),
    url: request.url,
    version: inertia_version
  }

  if inertia_request?
    response['Content-Type'] = 'application/json'
    response['X-Inertia'] = 'true'
    page_data.to_json
  else
    # HTML rendering - next task
    page_data.to_json
  end
end

def inertia_shared_data
  {}
end

private

def inertia_version
  version = opts[:inertia_version]
  version.respond_to?(:call) ? version.call : version
end
```

**Step 4: Run tests to verify they pass**

Run: `bundle exec rake test`
Expected: 5 tests, 0 failures

**Step 5: Commit**

```bash
git add -A
git commit -m "feat: add inertia method with JSON rendering"
```

---

### Task 4: HTML Rendering for Initial Page Load

**Files:**
- Create: `test/inertia_render_html_test.rb`
- Create: `test/views/inertia.erb`
- Create: `test/views/layout.erb`
- Modify: `lib/roda/plugins/inertia.rb`

**Step 1: Create test views**

```erb
<!-- test/views/layout.erb -->
<!DOCTYPE html>
<html>
<head><title>Test</title></head>
<body><%= yield %></body>
</html>
```

```erb
<!-- test/views/inertia.erb -->
<div id="app" data-page='<%= @inertia_page_data %>'></div>
```

**Step 2: Write failing test for HTML rendering**

```ruby
# test/inertia_render_html_test.rb
require_relative 'test_helper'
require 'json'

class InertiaRenderHtmlTest < InertiaTest
  def app
    Class.new(Roda) do
      plugin :inertia, version: '1.0'
      opts[:root] = File.dirname(__FILE__)

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
```

**Step 3: Run test to verify it fails**

Run: `bundle exec rake test`
Expected: FAIL (HTML not rendering correctly)

**Step 4: Update inertia method for HTML rendering**

Update `lib/roda/plugins/inertia.rb`, modify the `inertia` method:

```ruby
def inertia(component, props: {})
  page_data = {
    component: component,
    props: inertia_shared_data.merge(props),
    url: request.url,
    version: inertia_version
  }

  if inertia_request?
    response['Content-Type'] = 'application/json'
    response['X-Inertia'] = 'true'
    page_data.to_json
  else
    @inertia_page_data = page_data.to_json
    view(opts[:inertia_template])
  end
end
```

**Step 5: Run tests to verify they pass**

Run: `bundle exec rake test`
Expected: 8 tests, 0 failures

**Step 6: Commit**

```bash
git add -A
git commit -m "feat: add HTML rendering for initial page loads"
```

---

### Task 5: Shared Data

**Files:**
- Create: `test/inertia_shared_data_test.rb`

**Step 1: Write test for shared data**

```ruby
# test/inertia_shared_data_test.rb
require_relative 'test_helper'
require 'json'

class InertiaSharedDataTest < InertiaTest
  def app
    Class.new(Roda) do
      plugin :inertia, version: '1.0'

      def inertia_shared_data
        { shared_key: 'shared_value' }
      end

      route do |r|
        r.root do
          inertia 'Home', props: { local_key: 'local_value' }
        end
      end
    end
  end

  def test_merges_shared_data_into_props
    header 'X-Inertia', 'true'
    get '/'

    data = JSON.parse(last_response.body)
    assert_equal 'shared_value', data['props']['shared_key']
    assert_equal 'local_value', data['props']['local_key']
  end

  def test_local_props_override_shared_data
    app_with_override = Class.new(Roda) do
      plugin :inertia

      def inertia_shared_data
        { key: 'shared' }
      end

      route do |r|
        r.root do
          inertia 'Home', props: { key: 'local' }
        end
      end
    end

    @app = app_with_override
    header 'X-Inertia', 'true'
    get '/'

    data = JSON.parse(last_response.body)
    assert_equal 'local', data['props']['key']
  end

  def app
    @app || super
  end
end
```

**Step 2: Run tests to verify they pass**

Run: `bundle exec rake test`
Expected: 10 tests, 0 failures (shared data already implemented)

**Step 3: Commit**

```bash
git add -A
git commit -m "test: add shared data tests"
```

---

### Task 6: Inertia Redirects

**Files:**
- Create: `test/inertia_redirect_test.rb`
- Modify: `lib/roda/plugins/inertia.rb`

**Step 1: Write failing test for redirects**

```ruby
# test/inertia_redirect_test.rb
require_relative 'test_helper'

class InertiaRedirectTest < InertiaTest
  def app
    Class.new(Roda) do
      plugin :inertia

      route do |r|
        r.post 'submit' do
          inertia_redirect '/destination'
        end

        r.get 'redirect' do
          inertia_redirect '/destination'
        end

        r.get 'external' do
          inertia_redirect 'https://example.com/path'
        end
      end
    end
  end

  def test_regular_redirect_uses_302
    get '/redirect'
    assert_equal 302, last_response.status
    assert_equal '/destination', last_response['Location']
  end

  def test_inertia_get_redirect_uses_302
    header 'X-Inertia', 'true'
    get '/redirect'
    assert_equal 302, last_response.status
  end

  def test_inertia_post_redirect_uses_303
    header 'X-Inertia', 'true'
    post '/submit'
    assert_equal 303, last_response.status
    assert_equal '/destination', last_response['Location']
  end

  def test_external_redirect_uses_409_with_location_header
    header 'X-Inertia', 'true'
    get '/external'
    assert_equal 409, last_response.status
    assert_equal 'https://example.com/path', last_response['X-Inertia-Location']
  end

  def test_external_redirect_regular_request_uses_302
    get '/external'
    assert_equal 302, last_response.status
    assert_equal 'https://example.com/path', last_response['Location']
  end
end
```

**Step 2: Run test to verify it fails**

Run: `bundle exec rake test`
Expected: FAIL with "undefined method `inertia_redirect'"

**Step 3: Implement inertia_redirect**

Update `lib/roda/plugins/inertia.rb`, add to InstanceMethods:

```ruby
def inertia_redirect(path, status: nil)
  if inertia_request?
    status ||= request.get? ? 302 : 303

    if external_url?(path)
      response.status = 409
      response['X-Inertia-Location'] = path
      ''
    else
      redirect(path, status)
    end
  else
    redirect(path, status || 302)
  end
end

private

def external_url?(path)
  return false unless path.start_with?('http://', 'https://')
  uri = URI.parse(path)
  uri.host != request.host
rescue URI::InvalidURIError
  false
end
```

Also add `require 'uri'` at the top of the file.

**Step 4: Run tests to verify they pass**

Run: `bundle exec rake test`
Expected: 15 tests, 0 failures

**Step 5: Commit**

```bash
git add -A
git commit -m "feat: add inertia_redirect with 303 and external URL support"
```

---

### Task 7: Asset Version Checking

**Files:**
- Create: `test/inertia_version_test.rb`
- Modify: `lib/roda/plugins/inertia.rb`

**Step 1: Write failing test for version checking**

```ruby
# test/inertia_version_test.rb
require_relative 'test_helper'

class InertiaVersionTest < InertiaTest
  def app
    Class.new(Roda) do
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

  def app
    @app || super
  end
end
```

**Step 2: Run test to verify it fails**

Run: `bundle exec rake test`
Expected: FAIL (version checking not implemented)

**Step 3: Update inertia method with version checking**

Update `lib/roda/plugins/inertia.rb`, modify the `inertia` method to add version check at the start:

```ruby
def inertia(component, props: {})
  if inertia_request? && version_stale?
    response.status = 409
    response['X-Inertia-Location'] = request.url
    return ''
  end

  page_data = {
    component: component,
    props: inertia_shared_data.merge(props),
    url: request.url,
    version: inertia_version
  }

  if inertia_request?
    response['Content-Type'] = 'application/json'
    response['X-Inertia'] = 'true'
    page_data.to_json
  else
    @inertia_page_data = page_data.to_json
    view(opts[:inertia_template])
  end
end
```

Add the `version_stale?` private method:

```ruby
def version_stale?
  client_version = request.get_header('HTTP_X_INERTIA_VERSION')
  server_version = inertia_version

  server_version && client_version && client_version != server_version.to_s
end
```

**Step 4: Run tests to verify they pass**

Run: `bundle exec rake test`
Expected: 19 tests, 0 failures

**Step 5: Commit**

```bash
git add -A
git commit -m "feat: add asset version checking with 409 on mismatch"
```

---

### Task 8: Final Cleanup and README

**Files:**
- Create: `README.md`
- Review: All files for consistency

**Step 1: Create README**

```markdown
# inertia-roda

A Roda plugin providing server-side Inertia.js adapter.

## Installation

Add to your Gemfile:

```ruby
gem 'inertia-roda'
```

## Usage

```ruby
class App < Roda
  plugin :inertia, version: '1.0'

  def inertia_shared_data
    { current_user: current_user }
  end

  route do |r|
    r.get 'users' do
      inertia 'Users/Index', props: { users: User.all }
    end

    r.post 'users' do
      User.create(r.params)
      inertia_redirect '/users'
    end
  end
end
```

Create `views/inertia.erb`:

```erb
<div id="app" data-page='<%= @inertia_page_data %>'></div>
```

And `views/layout.erb` with your assets:

```erb
<!DOCTYPE html>
<html>
<head>
  <title>My App</title>
  <%= vite_client_tag %>
  <%= vite_javascript_tag 'application' %>
</head>
<body>
  <%= yield %>
</body>
</html>
```

## API

### `inertia(component, props: {})`

Renders an Inertia response. Returns JSON for Inertia requests, HTML for initial page loads.

### `inertia_redirect(path, status: nil)`

Redirects with Inertia-aware status codes. Uses 303 for non-GET requests.

### `inertia_shared_data`

Override to provide shared props for all responses.

## Configuration

```ruby
plugin :inertia,
  version: '1.0',           # Asset version (string or callable)
  template: 'inertia'       # ERB template name (default: 'inertia')
```

## License

MIT
```

**Step 2: Run full test suite**

Run: `bundle exec rake test`
Expected: 19 tests, 0 failures

**Step 3: Commit**

```bash
git add -A
git commit -m "docs: add README with usage examples"
```

---

## Summary

After completing all tasks, the gem will have:

- **Plugin**: `lib/roda/plugins/inertia.rb` (~80 lines)
- **Tests**: 19 tests covering all functionality
- **Documentation**: README with usage examples

The implementation follows TDD with frequent commits. Each task builds on the previous one.
