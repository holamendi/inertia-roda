# Inertia + Roda + React Example

A minimal example demonstrating inertia-roda with React and Vite.

## Setup

```bash
# Install Ruby dependencies
bundle install

# Install JavaScript dependencies
npm install

# Build frontend assets
npm run build
```

## Running

```bash
bundle exec puma
```

Visit http://localhost:9292

## Development with HMR

For hot module replacement during development:

```bash
# Terminal 1: Start Vite dev server
npm run dev

# Terminal 2: Start Roda app
bundle exec puma
```

Then update `views/layout.erb` to point to the Vite dev server:
```erb
<script type="module" src="http://localhost:5173/frontend/application.jsx"></script>
```

## Structure

```
├── app.rb                    # Roda application
├── config.ru                 # Rack config
├── views/
│   ├── layout.erb            # HTML layout
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
