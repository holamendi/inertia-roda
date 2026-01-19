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

        def inertia(component, props: {})
          page_data = {
            component: component,
            props: inertia_shared_data.merge(props),
            url: request.url,
            version: inertia_version
          }

          if inertia_request?
            response['Content-Type'] = 'application/json'
            response['X-Inertia'] = 'true'
            page_data.to_json
          else
            # HTML rendering - next task
            page_data.to_json
          end
        end

        def inertia_shared_data
          {}
        end

        private

        def inertia_version
          version = opts[:inertia_version]
          version.respond_to?(:call) ? version.call : version
        end
      end
    end

    register_plugin(:inertia, Inertia)
  end
end
