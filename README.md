# Inertia.js Roda adapter

## Installation

Add to your Gemfile:

```ruby
gem "inertia-roda"
```

## Usage

The plugin automatically loads Roda's `render` plugin, so your layout template is used for initial page loads. You can still customize `render` options (views path, layout name, etc.) by loading it yourself:

```ruby
class App < Roda
  plugin :inertia, version: "1.0"
  plugin :render, views: "app/views", layout: "my_layout" # optional

  USERS = [{ id: 1, name: "Alice" }, { id: 2, name: "Bob" }]

  def inertia_share
    {current_user: USERS.first}
  end

  route do |r|
    r.get "users" do
      inertia "Users/Index", props: { users: USERS }
    end

    r.post "users" do
      USERS << { id: USERS.size + 1, name: "New User" }
      inertia_redirect "/users"
    end
  end
end
```

`views/layout.erb`:

```erb
<!DOCTYPE html>
<html>
<head>
  <title>My App</title>
</head>
<body>
  <%= yield %>
</body>
</html>
```

## API

### `inertia(component, props: {})`

Renders an Inertia response. Returns JSON for Inertia requests, or a full HTML page (via the layout) for initial page loads. The `inertia_root` helper is called to generate the root `<div>` with page data, which is then wrapped in your layout template.

### `inertia_redirect(path, status: nil)`

Redirects with Inertia-aware status codes. For Inertia requests, non-GET methods default to 303. External URLs (different host) return a 409 with an `X-Inertia-Location` header. You can override the status code:

```ruby
inertia_redirect "/destination", status: 301
```

### `inertia_share`

Override this method to provide shared props merged into every Inertia response:

```ruby
def inertia_share
  { current_user: current_user }
end
```

### `inertia_root(id: "app")`

Renders the root `<div>` element with serialized page data. Override to customize the container ID:

```ruby
def inertia_root(id: "app")
  super(id: "my-app")
end
```

## Configuration

```ruby
plugin :inertia, version: "1.0" # Asset version (string or proc)
```
## Vite Integration

Add [vite_roda](https://github.com/holamendi/vite_roda) to your Gemfile:

```ruby
plugin :vite
plugin :inertia, version: ViteRuby.digest
```
