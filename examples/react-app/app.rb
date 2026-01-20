# frozen_string_literal: true

require "bundler/setup"
require "roda"
require "inertia_roda"
require "vite_roda"

class App < Roda
  plugin :vite
  plugin :inertia, version: "1.0"

  def inertia_shared_data
    {
      app_name: "Inertia + Roda Example"
    }
  end

  route do |r|
    r.vite_assets

    r.root do
      inertia "Home", props: {
        message: "Welcome to Inertia.js with Roda!"
      }
    end

    r.on "users" do
      r.is do
        r.get do
          users = [
            {id: 1, name: "Alice", email: "alice@example.com"},
            {id: 2, name: "Bob", email: "bob@example.com"},
            {id: 3, name: "Charlie", email: "charlie@example.com"}
          ]
          inertia "Users/Index", props: {users: users}
        end

        r.post do
          # Create user logic would go here
          inertia_redirect "/users"
        end
      end

      r.on Integer do |id|
        user = {id: id, name: "User #{id}", email: "user#{id}@example.com"}

        r.get do
          inertia "Users/Show", props: {user: user}
        end
      end
    end
  end
end
