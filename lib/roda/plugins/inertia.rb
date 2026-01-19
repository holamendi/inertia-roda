# lib/roda/plugins/inertia.rb
require "json"
require "uri"

class Roda
  module RodaPlugins
    module Inertia
      def self.load_dependencies(app, opts = {})
        app.plugin :render
        app.plugin :h
      end

      def self.configure(app, opts = {})
        app.opts[:inertia_version] = opts[:version]
        app.opts[:inertia_template] = opts[:template] || "inertia"
      end

      module InstanceMethods
        def inertia_request?
          request.get_header("HTTP_X_INERTIA") == "true"
        end

        def inertia(component, props: {})
          if request.get? && inertia_request? && version_stale?
            response.status = 409
            response["X-Inertia-Location"] = request.url
            return ""
          end

          page_data = {
            component: component,
            props: inertia_shared_data.merge(props),
            url: request.url,
            version: inertia_version
          }

          if inertia_request?
            response["Content-Type"] = "application/json"
            response["X-Inertia"] = "true"
            page_data.to_json
          else
            @inertia_page_data = page_data.to_json
            view(opts[:inertia_template])
          end
        end

        def inertia_shared_data
          {}
        end

        def inertia_redirect(path, status: nil)
          if inertia_request?
            status ||= request.get? ? 302 : 303

            if external_url?(path)
              response.status = 409
              response["X-Inertia-Location"] = path
              ""
            else
              request.redirect(path, status)
            end
          else
            request.redirect(path, status || 302)
          end
        end

        private

        def version_stale?
          client_version = request.get_header("HTTP_X_INERTIA_VERSION")
          server_version = inertia_version

          server_version && client_version && client_version != server_version.to_s
        end

        def external_url?(path)
          return false unless path.start_with?("http://", "https://")
          uri = URI.parse(path)
          uri.host != request.host
        rescue URI::InvalidURIError
          false
        end

        def inertia_version
          version = opts[:inertia_version]
          version.respond_to?(:call) ? version.call : version
        end
      end
    end

    register_plugin(:inertia, Inertia)
  end
end
