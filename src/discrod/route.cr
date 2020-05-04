module Discrod
    DISCORD_URL = "discordapp.com"
    DISCORD_API_VERSION = "v6"

    class RouteException < Exception
        def initialize(@status : HTTP::Status)
        end

        def message
            "The server responded with code #{@status.code}: #{@status.description}"
        end
    end

    class RouteClient
        alias FormValue = Nil | Bool | Int64 | Float64 | String | Array(FormValue) | Form
        alias Form = Hash(String, FormValue) | String

        def simplify_form(form : Form)
            return "" if form.nil?
            return form if form.is_a?(String)
            form.to_json
        end

        def initialize(@authorization : String)
            @http = HTTP::Client.new DISCORD_URL, tls: true
            @http.before_request { |r| r.headers["Authorization"] = @authorization }
        end

        def get(route : Route)
            response = @http.get(route.path)
            raise RouteException.new(response.status) unless response.success?
            response.body
        end

        def post(route : Route, form : Form? = nil)
            response = @http.post(route.path, headers: HTTP::Headers{"Content-Type" => "application/json"}, body: simplify_form(form))
            raise RouteException.new(response.status) unless response.success?
            response.body
        end

        def patch(route : Route, form : Form? = nil)
            response = @http.patch(route.path, headers: HTTP::Headers{"Content-Type" => "application/json"}, body: simplify_form(form))
            raise RouteException.new(response.status) unless response.success?
            response.body
        end

        def put(route : Route, form : Form? = nil)
            response = @http.put(route.path, headers: HTTP::Headers{"Content-Type" => "application/json"}, body: simplify_form(form))
            raise RouteException.new(response.status) unless response.success?
            response.body
        end

        def delete(route : Route)
            response = @http.delete(route.path)
            raise RouteException.new(response.status) unless response.success?
            response.body
        end
    end

    # Represents a route to Discord's API.
    struct Route
        def path
            "#{@base}#{@endpoint}"
        end

        def initialize(@endpoint : String, @base : String = "/api/#{DISCORD_API_VERSION}")
        end

        def +(node : String)
            Route.new "#{@endpoint}/#{node}"
        end
    end
end
