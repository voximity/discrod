module Discrod
    extend self

    @@client : Client? = nil

    # The default `Client` of the module.
    def client : Client
        return @@client.not_nil! unless @@client.nil?
        raise "a Client has not yet been instantiated, so operations may not be performed on resources."
    end

    # Sets the default `Client` of the module.
    def client=(client : Client)
        @@client = client
    end

    def log
        ::Log.for("discrod")
    end

    # The token type of the client. Default is `Bot`.
    enum TokenType
        Bot
        Bearer
    end

    # A `Client`. Responsible for handling WebSocket interactions (see `Discrod::WS::WebSocket`) and REST interactions.
    class Client
        @web_socket : WS::WebSocket?

        getter token
        getter token_type

        macro cache(cache_name)
            getter {{cache_name}}_cache : {{cache_name.id.capitalize}}Cache?
            def {{cache_name}}_cache! : {{cache_name.id.capitalize}}Cache
                return {{cache_name}}_cache.not_nil! unless {{cache_name}}_cache.nil?
                raise "no cache exists, making this resolution invalid"
            end
        end

        cache guild
        cache channel
        cache user
        cache role

        getter route_client : RouteClient
        getter dead : Bool = false

        # Instantiate a client.
        def initialize(@token : String = "", @token_type : TokenType = TokenType::Bot, use_cache : Bool = true)
            @route_client = RouteClient.new("#{@token_type.to_s} #{@token}")
            @web_socket = WS::WebSocket.new(self)

            if use_cache
                @guild_cache = GuildCache.new(self)
                @channel_cache = ChannelCache.new(self)
                @user_cache = UserCache.new(self)
                @role_cache = RoleCache.new(self)
            end

            Discrod.client = self
        end

        def authorization
            "#{@token_type.to_s} #{@token}"
        end

        # Attempt to establish a connection to the gateway.
        def connect
            raise "client is dead" if dead
            @web_socket.try &.run
        end

        def close
            @dead = true
            @web_socket.should_reconnect = false
            @web_socket.close
            @guild_cache.client_dead = true
            @channel_cache.client_dead = true
            @user_cache.client_dead = true
            @role_cache.client_dead = true
        end

        # REST events

        # Gets the gateway from Discord's API.
        def get_gateway : String
            payload = WS::GatewayPayload.from_json @route_client.get Route.new "/gateway"
            payload.gateway
        end

        @gateway : String? = nil

        # The websocket gateway. Uses cached gateway unless it is not already cached.
        def gateway : String
            @gateway ||= get_gateway
        end

        include REST::ChannelEndpoints
        include REST::EmojiEndpoints
        include REST::GuildEndpoints
        include REST::UserEndpoints

        include WS::Events
    end
end
