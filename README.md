# Inertia.js Roda Adapter

Server-side [Inertia.js](https://inertiajs.com) adapter for [Roda](https://roda.jeremyevans.net).

## Installation

Add to your Gemfile:

```ruby
gem "inertia-roda"
```

## Quick Start

```ruby
class App < Roda
  plugin :inertia, version: "1.0"

  def inertia_share
    { user: { email: "bobbytables@example.com"} }
  end

  route do |r|
    r.get "dashboard" do
      inertia "Dashboard", props: { name: "Alice" }
    end

    r.post "logout" do
      logout!
      inertia_redirect "/login"
    end
  end
end
```

The plugin loads Roda's `render` plugin automatically. Your layout template calls `inertia_root` to render the root `<div>` with page data:

`views/layout.erb`:

```erb
<!DOCTYPE html>
<html>
<head>
  <title>My App</title>
  <!-- Your JS and CSS assets go here (see Vite Integration below) -->
</head>
<body>
  <%= inertia_root %>
</body>
</html>
```

To customize the views path or layout name, load the `render` plugin yourself:

```ruby
plugin :render, views: "app/views", layout: "my_layout"
```

## Vite Integration

`inertia-roda` pairs well with [vite_roda](https://github.com/holamendi/vite_roda) for asset management and hot reloading:

```ruby
plugin :vite
plugin :inertia, version: -> { ViteRuby.digest }
```

Use the Vite helpers in your layout to load your frontend entrypoint:

```erb
<!DOCTYPE html>
<html>
<head>
  <%= vite_client_tag %>
  <%= vite_javascript_tag "application" %>
</head>
<body>
  <%= inertia_root %>
</body>
</html>
```

## API

### `inertia(component, props: {})`

Renders an Inertia response. Returns JSON for Inertia requests, or a full HTML page (via layout) for initial page loads. Shared props from `inertia_share` are merged in automatically.

### `inertia_redirect(path, status: nil)`

Inertia-aware redirect. For Inertia requests with non-GET methods, defaults to 303 (forcing a GET). External URLs (different host) return a 409 with `X-Inertia-Location` header. You can override the status:

```ruby
inertia_redirect "/destination", status: 301
```

### `inertia_share`

Provide shared props merged into every response:

```ruby
def inertia_share
  { user: { email: "bobbytables@example.com"} }
end
```

## License

MIT
