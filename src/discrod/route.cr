module Discrod
    DISCORD_URL = "www.discordapp.com"
    DISCORD_API_VERSION = "v6"

    class RouteException < Exception
        def initialize(@status : HTTP::Status)
        end

        def message
            "The server responded with code #{@status.code}: #{@status.description}"
        end
    end

    class RouteClient
        def initialize(@authorization : String)
            @http = HTTP::Client.new "www.discordapp.com", tls: true
            @http.before_request &.headers["Authorization"] = @authorization
        end

        def get(route : Route)
            response = @http.get(route.path)
            raise RouteException.new(response.status) unless response.success?
            response.body
        end

        def post(route : Route, form : JSON::Any)
            response = @http.post(route.path, headers: HTTP::Headers{"Content-Type" => "application/json"}, body: form.to_json)
            raise RouteException.new(response.status) unless response.success?
            response.body
        end
    end

    # Represents a route to Discord's API.
    struct Route
        def path
            "#{@base}/#{@endpoint}"
        end

        def initialize(@endpoint : String, @base : String = "/api/#{DISCORD_API_VERSION}")
        end

        def +(node : String)
            Route.new "#{@endpoint}/#{node}"
        end
    end
end
