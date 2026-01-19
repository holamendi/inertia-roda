# lib/roda/plugins/inertia.rb
require 'json'

class Roda
  module RodaPlugins
    module Inertia
      def self.load_dependencies(app, opts = {})
        app.plugin :render
      end

      def self.configure(app, opts = {})
        app.opts[:inertia_version] = opts[:version]
        app.opts[:inertia_template] = opts[:template] || 'inertia'
      end

      module InstanceMethods
        def inertia_request?
          request.get_header('HTTP_X_INERTIA') == 'true'
        end
      end
    end

    register_plugin(:inertia, Inertia)
  end
end
