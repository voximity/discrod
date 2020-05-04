module Discrod
    extend self

    def log
        ::Log.for("discrod")
    end

    # The token type of the client. Default is `Bot`.
    enum TokenType
        Bot
        Bearer
    end

    class Client
        @web_socket : WS::WebSocket?

        getter token
        getter token_type

        getter guild_cache : GuildCache?
        getter channel_cache : ChannelCache?
        getter user_cache : UserCache?
        getter role_cache : RoleCache?

        getter route_client : RouteClient

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
        end

        def authorization
            "#{@token_type.to_s} #{@token}"
        end

        # Attempt to establish a connection to the gateway.
        def connect
            @web_socket.try &.run
        end

        # REST events

        # Gets a guild from Discord's API, skipping the cache. Use the cache to get guilds if you do not wish to request the API.
        def get_guild(id : Snowflake)
            body = @route_client.get Route.new "guilds" + "#{id.value}"
            Guild.from_json body
        end

        # :nodoc:
        macro event(name, *params)
            def on_{{name}}(&block : {{*params}} ->)
                @{{name}}_listeners << block
            end
            protected def fire_{{name}}(*args)
                @{{name}}_listeners.try &.each &.call(*args)
            end
            {% if params.size == 0 %}
                @{{name}}_listeners : Array(Proc(Nil)) = [] of Proc(Nil)
            {% else %}
                @{{name}}_listeners : Array(Proc({{*params}}, Nil)) = [] of Proc({{*params}}, Nil)
            {% end %}
        end

        # This event is fired when the client successfully connects to the gateway
        # and downloads necessary information.
        event ready

        # This event is fired when a channel is created.
        #
        # https://discordapp.com/developers/docs/topics/gateway#channel-create
        event channel_create, Channel

        # This event is fired when a channel is updated. The passed argument is the new channel.
        #
        # https://discordapp.com/developers/docs/topics/gateway#channel-update
        event channel_update, Channel

        # This event is fired when a channel is deleted. The passed argument is the channel prior to deletion.
        #
        # https://discordapp.com/developers/docs/topics/gateway#channel-delete
        event channel_delete, Channel

        # This event is fired when a channel's pins are updated. Not sent when a pinned message is deleted.
        # The passed argument is a `ChannelPinsUpdate`.
        #
        # https://discordapp.com/developers/docs/topics/gateway#channel-pins-update
        event channel_pins_update, ChannelPinsUpdate

        # This event is fired when a guild is created, downloaded, or becomes available. This also updates the guild in the client's cache.
        #
        # https://discordapp.com/developers/docs/topics/gateway#guild-create
        event guild_create, Guild

        # This event is fired when a guild is updated. This also updates the guild in the client's cache.
        #
        # https://discordapp.com/developers/docs/topics/gateway#guild-update
        event guild_update, Guild

        # This event is fired when a guild becomes unavailable, or the current user leaves the guild.
        # The argument, a `Guild?`, is passed if the guild was present in the cache prior to deletion.
        #
        # https://discordapp.com/developers/docs/topics/gateway#guild-delete
        event guild_delete, Guild?

        # This event is fired when a user is banned from a guild. `Guild?` is not nil when the guild is present in
        # the cache.
        #
        # https://discordapp.com/developers/docs/topics/gateway#guild-ban-add
        event guild_ban_add, User, Guild?

        # This event is fired when a user is unbanned from a guild.
        #
        # https://discordapp.com/developers/docs/topics/gateway#guild-ban-remove
        event guild_ban_remove, User, Guild?

        # This event is fired when a guild emoji is updated.
        #
        # https://discordapp.com/developers/docs/topics/gateway#guild-emojis-update
        event guild_emojis_update, Array(GuildEmoji), Guild?

        # This event is fired when a guild's integrations are updated.
        #
        # https://discordapp.com/developers/docs/topics/gateway#guild-integrations-update
        event guild_integrations_update, Guild?

        # This event is fired when a user joins a guild.
        #
        # https://discordapp.com/developers/docs/topics/gateway#guild-member-add
        event guild_member_add, Member, Guild?

        # This event is fired when a user leaves a guild.
        #
        # https://discordapp.com/developers/docs/topics/gateway#guild-member-remove
        event guild_member_remove, User, Guild?

        # This event is fired when a member is modified in a guild.
        #
        # https://discordapp.com/developers/docs/topics/gateway#guild-member-upddate
        event guild_member_update, MemberUpdate, Guild?

        # event guild_members_chunk

        # This event is fired when a role is created.
        #
        # https://discordapp.com/developers/docs/topics/gateway#guild-role-create
        event guild_role_create, Role, Guild?

        # This event is fired when a role is updated.
        #
        # https://discordapp.com/developers/docs/topics/gateway#guild-role-create
        event guild_role_update, Role, Guild?

        # This event is fired when a role is deleted. The Role object is only available if caching is enabled.
        #
        # https://discordapp.com/developers/docs/topics/gateway#guild-role-create
        event guild_role_delete, Role?, Guild?

        # This event is fired when an invite is created.
        #
        # https://discordapp.com/developers/docs/topics/gateway#guild-role-create
        event invite_create, Invite, Channel?, Guild?

        # This event is fired when an invite is removed.
        #
        # https://discordapp.com/developers/docs/topics/gateway#guild-role-create
        event invite_delete, String, Channel?, Guild?

        # This event is fired when the client receives a message.
        #
        # https://discordapp.com/developers/docs/topics/gateway#message-create
        event message_create, Message
    end
end
