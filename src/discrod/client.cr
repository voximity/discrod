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
            @web_socket.try &.run
        end

        # REST events

        # Gets the gateway from Discord's API.
        def get_gateway : String
            payload = GatewayPayload.from_json @route_client.get Route.new "/gateway"
            payload.gateway
        end

        @gateway : String? = nil

        # The websocket gateway. Uses cached gateway unless it is not already cached.
        def gateway : String
            @gateway ||= get_gateway
        end

        # Gets a guild from Discord's API, skipping the cache. Use the cache to get guilds if you do not wish to request the API.
        def get_guild(id : Snowflake | UInt64) : Guild
            body = @route_client.get Route.new "/guilds/#{id.to_s}"
            Guild.from_json body
        end

        # Gets a channel from Discord's API, skipping the cache. Use the cache to get channels if you do not wish to request the API.
        #
        # https://discordapp.com/developers/docs/resources/channel#get-channel
        def get_channel(id : Snowflake | UInt64) : Channel
            body = @route_client.get Route.new "/channels/#{id.to_s}"
            Channel.from_json body
        end

        # Modify channel

        # Deletes a channel.
        #
        # https://discordapp.com/developers/docs/resources/channel#deleteclose-channel
        def delete_channel(id : Snowflake | UInt64)
            @route_client.delete Route.new "/channels/#{id.to_s}"
        end

        # Gets an `Array(Message)` based on the search criteria given.
        #
        # https://discordapp.com/developers/docs/resources/channel#get-channel-messages
        def get_channel_messages(channel_id : Snowflake | UInt64, message_id : Snowflake | UInt64, direction : SnowflakeDirection, limit : Int32 = 50) : Array(Message)
            query = {} of String => String | Int32
            query["limit"] = limit
            query[direction.to_s.downcase] = message_id.to_s
            Array(Message).from_json @route_client.get Route.new "/channels/#{channel_id}/messages?#{query.map { |k, v| "#{k}=#{v}" }.join "&"}"
        end

        # Gets a message from a channel.
        #
        # https://discordapp.com/developers/docs/resources/channel#get-channel-message
        def get_channel_message(channel_id : Snowflake | UInt64, message_id : Snowflake | UInt64) : Message
            Message.from_json @route_client.get Route.new "/channels/#{channel_id.to_s}/messages/#{message_id.to_s}"
        end

        # Creates a message in a channel.
        #
        # https://discordapp.com/developers/docs/resources/channel#create-message
        def create_message(
            channel_id : Snowflake | UInt64,
            content : String? = nil,
            nonce : String | Int32 | Nil = nil,
            tts : Bool? = nil,
            embed : Embed? = nil
            # payload_json,
            # allowed_mentions
        ) : Message
            raise "content or embed is required for creating a message" if content.nil? && embed.nil?
            body = @route_client.post Route.new("/channels/#{channel_id.to_s}/messages"), MessageCreatePayload.new(
                content: content,
                nonce: nonce,
                tts: tts,
                embed: embed
            ).to_json
            Message.from_json body
        end

        # Creates a reaction on a message.
        #
        # https://discordapp.com/developers/docs/resources/channel#create-reaction
        def create_reaction(
            channel_id : Snowflake | UInt64,
            message_id : Snowflake | UInt64,
            emoji : AbstractEmoji
        )
            @route_client.put Route.new("/channels/#{channel_id.to_s}/messages/#{message_id.to_s}/reactions/#{URI.encode emoji.to_s}/@me")
        end

        # Remove a reaction from a message. Pass nil for `user_id` to specify yourself.
        #
        # https://discordapp.com/developers/docs/resources/channel#create-reaction
        def delete_reaction(
            channel_id : Snowflake | UInt64,
            message_id : Snowflake | UInt64,
            emoji : AbstractEmoji,
            user_id : (Snowflake | UInt64)? = nil
        )
            @route_client.delete Route.new("/channels/#{channel_id.to_s}/messages/#{message_id.to_s}/reactions/#{URI.encode emoji.to_s}/#{(user_id || "@me").to_s}")
        end

        # Get reactions from a message. Has a hard limit of 100 users per request. `SnowflakeDirection::Around` is not valid here and will throw an error.
        #
        # https://discordapp.com/developers/docs/resources/channel#get-reactions
        def get_reactions(
            channel_id : Snowflake | UInt64,
            message_id : Snowflake | UInt64,
            emoji : AbstractEmoji,
            limit : Int32 = 25,
            user_id : (Snowflake | UInt64)? = nil,
            direction : SnowflakeDirection? = nil
        ) : Array(User)
            raise "SnowflakeDirection::Around is invalid for get_reactions" if direction == SnowflakeDirection::Around
            query = {} of String => String | Int32
            query["limit"] = limit
            query[direction.to_s.downcase] = user_id unless user_id.nil?

            body = @route_client.get Route.new "/channels/#{channel_id.to_s}/messages/#{message_id.to_s}/reactions/#{URI.encode emoji.to_s}?#{query.map { |k, v| "#{k}=#{v}" }.join "&"}"
            Array(User).from_json body
        end

        # Deletes all reactions from a message.
        #
        # https://discordapp.com/developers/docs/resources/channel#delete-all-reactions
        def delete_all_reactions(
            channel_id : Snowflake | UInt64,
            message_id : Snowflake | UInt64
        )
            @route_client.delete Route.new "/channels/#{channel_id.to_s}/messages/#{message_id.to_s}/reactions"
        end

        # Deletes all reactions from a message matching a specific emoji.
        #
        # https://discordapp.com/developers/docs/resources/channel#delete-all-reactions-for-emoji
        def delete_all_reactions_for_emoji(
            channel_id : Snowflake | UInt64,
            message_id : Snowflake | UInt64,
            emoji : AbstractEmoji
        )
            @route_client.delete Route.new "/channels/#{channel_id.to_s}/messages/#{message_id.to_s}/reactions/#{URI.encode emoji.to_s}"
        end

        # Bulk delete messages. Requires an array of snowflake IDs.
        # This method will not work on messages older than two weeks.
        #
        # https://discordapp.com/developers/docs/resources/channel#bulk-delete-messages
        def bulk_delete_messages(
            channel_id : Snowflake | UInt64,
            message_ids : Array(Snowflake | UInt64)
        )
            raise "message_ids must have between 2 and 100 snowflakes" unless (2..100).includes?(message_ids.size)
            @route_client.post Route.new("/channels/#{channel_id.to_s}/messages/bulk-delete"), {
                "messages" => message_ids.map &.to_s
            }
        end

        # Edits channel permissions by an overwrite object.
        #
        # https://discordapp.com/developers/docs/resources/channel#edit-channel-permissions
        def edit_channel_permissions(
            channel_id : Snowflake | UInt64,
            overwrite : PermissionOverwrite
        )
            @route_client.put Route.new("/channels/#{channel_id.to_s}/permissions/#{overwrite.id.to_s}"), overwrite.to_json
        end

        # Get an `Array(Invite)` for a channel.
        #
        # https://discordapp.com/developers/docs/resources/channel#get-channel-invites
        def get_channel_invites(
            channel_id : Snowflake | UInt64
        ) : Array(Invite)
            Array(Invite).from_json @route_client.get Route.new "/channels/#{channel_id.to_s}/invites"
        end

        # Creates an `Invite` for a channel. Pass `max_age: Time::Span.zero` to set infinite lifetime.
        #
        # https://discordapp.com/developers/docs/resources/channel#create-channel-invite
        def create_channel_invite(
            channel_id : Snowflake | UInt64,
            max_age : Time::Span? = nil,
            max_uses : Int32 = 0,
            temporary : Bool = false,
            unique : Bool = false
        ) : Invite
            Invite.from_json @route_client.post Route.new("/channels/#{channel_id.to_s}/invites"), {
                "max_age" => (max_age || Time::Span.Zero).total_seconds.to_i,
                "max_uses" => max_uses,
                "temporary" => temporary,
                "unique" => unique
            }
        end

        # Deletes a channel permission overwrite.
        #
        # https://discordapp.com/developers/docs/resources/channel#delete-channel-permission
        def delete_channel_permission(
            channel_id : Snowflake | UInt64,
            overwrite_id : Snowflake | UInt64
        )
            @route_client.delete Route.new("/channels/#{channel_id.to_s}/permissions/#{overwrite_id.to_s}")
        end

        # Triggers the typing indicator in a channel. The indicator ends after five seconds or the next message sent, whichever comes first.
        #
        # https://discordapp.com/developers/docs/resources/channel#trigger-typing-indicator
        def trigger_typing_indicator(
            channel_id : Snowflake | UInt64
        )
            @route_client.post Route.new("/channels/#{channel_id.to_s}/typing")
        end

        # Gets an `Array(Message)` representing a channel's pins.
        #
        # https://discordapp.com/developers/docs/resources/channel#get-pinned-messages
        def get_pinned_messages(
            channel_id : Snowflake | UInt64
        ) : Array(Message)
            Array(Message).from_json @route_client.get Route.new("/channels/#{channel_id.to_s}/pins")
        end

        # Adds a message to a channel's pins. A hard cap of 50 pinned messages is present for all channels.
        #
        # https://discordapp.com/developers/docs/resources/channel#add-pinned-channel-message
        def add_pinned_channel_message(
            channel_id : Snowflake | UInt64,
            message_id : Snowflake | UInt64
        )
            @route_client.put Route.new("/channels/#{channel_id.to_s}/pins/#{message_id.to_s}")
        end

        # Removes a message from a channel's pins.
        #
        # https://discordapp.com/developers/docs/resources/channel#delete-pinned-channel-message
        def delete_pinned_channel_message(
            channel_id : Snowflake | UInt64,
            message_id : Snowflake | UInt64
        )
            @route_client.delete Route.new("/channels/#{channel_id.to_s}/pins/#{message_id.to_s}")
        end

        # do GDM endpoints even work for bots?

        # Gets a user from Discord's API, skipping the cache. Use the cache to get channels if you do not wish to request the API.
        def get_user(id : Snowflake | UInt64)
            body = @route_client.get Route.new("/users/#{id.to_s}")
            User.from_json body
        end

        # :nodoc:
        macro event(name, *params)
            {% listener_name = name.id.split("_").map(&.capitalize).join("").id %}
            def on_{{name}}(&block : {{*params}} ->) : Event{{listener_name}}Listener
                listener = Event{{listener_name}}Listener.new(block)
                @{{name}}_listeners << listener
                listener
            end
            protected def fire_{{name}}(*args)
                @{{name}}_listeners.try &.each &.call(*args)
            end
            # :nodoc:
            struct Event{{listener_name}}Listener
                {% if params.size == 0 %}
                    getter proc : Proc(Nil)
                {% else %}
                    getter proc : Proc({{*params}}, Nil)
                {% end %}
                def call(*args)
                    @proc.call(*args)
                end
                def destroy
                    @{{name}}_listeners.delete(self)
                end
                def initialize(@proc)
                end
            end
            @{{name}}_listeners : Array(Event{{listener_name}}Listener) = [] of Event{{listener_name}}Listener
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

        # This event is fired when a message updates.
        #
        # https://discordapp.com/developers/docs/topics/gateway#message-update
        event message_update, Message

        # This event is fired when a message is deleted.
        #
        # https://discordapp.com/developers/docs/topics/gateway#message-delete
        event message_delete, Snowflake, Channel?, Guild?

        # This event is fired when messages are bulk deleted.
        #
        # https://discordapp.com/developers/docs/topics/gateway#message-delete-bulk
        event message_delete_bulk, Array(Snowflake), Channel?, Guild?

        # This event is fired when a user reacts to a message.
        # The parameter type is a `ReactionEvent`.
        #
        # https://discordapp.com/developers/docs/topics/gateway#message-reaction-add
        event message_reaction_add, ReactionEvent

        # This event is fired when a user removes a reaction from a message.
        # The parameter type is a `ReactionEvent`. The `member` field is not available in this event.
        #
        # https://discordapp.com/developers/docs/topics/gateway#message-reaction-add
        event message_reaction_remove, ReactionEvent

        # This event is fired when all reactions are removed from a message.
        #
        # https://discord.com/developers/docs/topics/gateway#message-reaction-remove-all
        event message_reaction_remove_all, Snowflake, Channel?, Guild?

        # This event is fired when a user removes all reactions of a certain emoji.
        #
        # https://discord.com/developers/docs/topics/gateway#message-reaction-remove-emoji
        event message_reaction_remove_emoji, AbstractEmoji, Snowflake, Channel?, Guild?
    end
end
