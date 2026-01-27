# Inertia.js Roda adapter

## Installation

Add to your Gemfile:

```ruby
gem "inertia-roda"
```

## Usage

```ruby
class App < Roda
  plugin :inertia, version: "1.0"

  def inertia_share
    {current_user:}
  end

  route do |r|
    r.get "users" do
      inertia "Users/Index", props: { users: User.all }
    end

    r.post "users" do
      User.create(r.params)
      inertia_redirect "/users"
    end
  end
end
```

The `inertia` method returns a `<div id="app">` element. To add your CSS/JS assets, use Roda's render plugin:

```ruby
class App < Roda
  plugin :render
  plugin :inertia, version: "1.0"

  def inertia(component, props: {})
    html = super
    view(inline: html, layout: true)
  end
end
```

Create `views/layout.erb`:

```erb
<!DOCTYPE html>
<html>
<head>
  <title>My App</title>
  <%= vite_client_tag %>
  <%= vite_javascript_tag "application" %>
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

### `inertia_share`

Provide shared props for all responses.

### `inertia_root(id: "app")`

Renders the root `<div>` element with page data.

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
