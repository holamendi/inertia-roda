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
  plugin :render

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
