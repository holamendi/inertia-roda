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
<div id="app" data-page="<%= h @inertia_page_data %>"></div>
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
