# inertia-roda Design

A Roda plugin providing an Inertia.js server-side adapter.

## Goals

- Provide Inertia.js support for Roda applications
- Framework-agnostic (React, Vue, Svelte)
- Minimal core, extensible later
- Clean, Roda-idiomatic API

## File Structure

```
inertia-roda/
├── lib/
│   ├── inertia_roda.rb          # gem entry point
│   └── roda/plugins/inertia.rb  # the actual Roda plugin
├── test/
│   ├── test_helper.rb
│   ├── inertia_render_test.rb
│   ├── inertia_redirect_test.rb
│   └── inertia_shared_data_test.rb
├── Gemfile
├── Rakefile
├── inertia-roda.gemspec
└── README.md
```

## Plugin Configuration

```ruby
plugin :inertia, version: '1.0', template: 'inertia'
```

Options:
- `version` - String or callable for asset versioning
- `template` - ERB template name (default: 'inertia')

The plugin auto-loads Roda's `render` plugin via `load_dependencies`.

## Core API

### Rendering

```ruby
inertia 'Component', props: { key: value }
```

Handles two cases:
1. **Inertia request** (XHR with `X-Inertia: true`) → Returns JSON
2. **Initial page load** → Returns HTML with embedded page data

JSON response structure:
```json
{
  "component": "Users/Index",
  "props": { "users": [...] },
  "url": "/users",
  "version": "1.0"
}
```

### Shared Data

Override `inertia_shared_data` instance method:

```ruby
def inertia_shared_data
  { current_user: current_user, flash: flash }
end
```

Default returns `{}`. Merged into every Inertia response.

### Redirects

```ruby
inertia_redirect '/path'
inertia_redirect 'https://external.com'
```

Behavior:
- Uses 303 status for PUT/PATCH/DELETE (forces GET)
- External URLs return 409 with `X-Inertia-Location` header
- Non-Inertia requests use standard 302

### Asset Versioning

Configured at plugin load:

```ruby
# Static
plugin :inertia, version: '1.0'

# Dynamic
plugin :inertia, version: -> { File.mtime('public/assets/manifest.json').to_i.to_s }
```

When client version (`X-Inertia-Version` header) doesn't match server version, returns 409 with `X-Inertia-Location` to force full reload.

## Implementation

### Plugin Structure

```ruby
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

        def inertia_shared_data
          {}
        end

        def inertia_request?
          request.get_header('HTTP_X_INERTIA') == 'true'
        end

        private

        def inertia_version
          version = opts[:inertia_version]
          version.respond_to?(:call) ? version.call : version
        end

        def version_stale?
          client_version = request.get_header('HTTP_X_INERTIA_VERSION')
          server_version = inertia_version

          server_version && client_version && client_version != server_version.to_s
        end

        def external_url?(path)
          return false unless path.start_with?('http://', 'https://')
          uri = URI.parse(path)
          uri.host != request.host
        end
      end
    end

    register_plugin(:inertia, Inertia)
  end
end
```

### ERB Template

User provides `views/inertia.erb`:

```erb
<div id="app" data-page='<%= @inertia_page_data %>'></div>
```

And a layout (`views/layout.erb`) with their asset tags.

## Testing

Using Minitest with Rack::Test:

```ruby
class InertiaTest < Minitest::Test
  include Rack::Test::Methods
end
```

Test cases:
- Rendering returns JSON for Inertia requests
- Rendering returns HTML for initial page loads
- Shared data is merged into props
- Redirects use 303 for non-GET requests
- External redirects return 409 with header
- Version mismatch returns 409

## Usage Example

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
      User.create(params)
      inertia_redirect '/users'
    end
  end
end
```

## Deferred Features

For future iterations:
- Partial reloads (`X-Inertia-Partial-Data`, `X-Inertia-Partial-Component`)
- Lazy props (evaluated only when requested)
- SSR support
- Testing helpers (assertions for component/props)
- History encryption
