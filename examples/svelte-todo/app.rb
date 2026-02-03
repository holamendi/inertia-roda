require "sequel"
require "roda"
require "vite_roda"
require "logger"

DB = Sequel.sqlite
DB.loggers << Logger.new($stderr)
DB.create_table? :todos do
  primary_key :id
  String :title, null: false
  TrueClass :completed, default: false
end

class Todo < Sequel::Model
  def to_hash
    {id: id, title: title, completed: completed}
  end
end

class App < Roda
  plugin :vite
  plugin :inertia, version: -> { ViteRuby.digest }
  plugin :json_parser
  plugin :all_verbs
  LOGGER = Logger.new($stderr)
  plugin :common_logger, LOGGER

  route do |r|
    r.public
    LOGGER.info("params: #{r.params}") unless r.params.empty?

    r.root do
      r.redirect "/todos"
    end

    r.on "todos" do
      r.get true do
        inertia "Todos", props: {todos: Todo.all.map(&:to_hash)}
      end

      r.post true do
        Todo.create(title: r.params["title"])
        inertia_redirect "/todos"
      end

      r.on Integer do |id|
        todo = Todo[id]

        r.put true do
          todo.update(completed: !todo.completed)
          inertia_redirect "/todos"
        end

        r.delete true do
          todo.destroy
          inertia_redirect "/todos"
        end
      end
    end
  end
end
