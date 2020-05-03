module Discrod
    # Represents a route to Discord's API.
    struct Route
        getter uri : URI

        def initialize(@endpoint : String, @base : String = "https://discordapp.com/api/v6")
            @uri = URI.parse "#{@base}#{@endpoint}"
        end

        def +(node : String)
            Route.new "#{@endpoint}/#{node}"
        end
    end
end
