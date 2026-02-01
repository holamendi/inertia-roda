# Todo App Example

A minimal todo list built with [inertia-roda](https://github.com/your/inertia-roda), Svelte, Vite, and Sequel (SQLite3).

## Setup

```bash
bundle install
npm install
```

## Run

```bash
npx foreman start -f Procfile.dev
```

Then open [http://localhost:9292](http://localhost:9292).

## How it works

- **`app.rb`** — Single-file Roda app with in-memory SQLite database, Inertia plugin, and CRUD routes
- **`frontend/pages/Todos.svelte`** — Svelte component that uses Inertia's router for form submissions and navigation
- **`frontend/entrypoints/application.js`** — Inertia + Svelte bootstrap
