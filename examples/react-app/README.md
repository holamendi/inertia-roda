# Inertia + Roda + React Example

A minimal example demonstrating inertia-roda with React and Vite.

## Setup

```bash
# Install Ruby dependencies
bundle install

# Install JavaScript dependencies
npm install
```

## Development

Run both the Vite dev server and the Roda app:

```bash
# Terminal 1: Start Vite dev server
npm run dev

# Terminal 2: Start Roda app
bundle exec puma
```

Visit http://localhost:9292

## Production Build

```bash
# Build frontend assets
npm run build

# Start server
bundle exec puma -e production
```

## Structure

```
├── app.rb                    # Roda application
├── config.ru                 # Rack config
├── views/
│   ├── layout.erb            # HTML layout with Vite tags
│   └── inertia.erb           # Inertia mount point
└── frontend/
    ├── application.jsx       # React entry point
    └── pages/
        ├── Home.jsx          # Home page component
        └── Users/
            ├── Index.jsx     # Users list
            └── Show.jsx      # User detail
```

## Routes

- `GET /` - Home page
- `GET /users` - Users list
- `GET /users/:id` - User detail
