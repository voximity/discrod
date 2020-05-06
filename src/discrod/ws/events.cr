module Discrod::WS::Events
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
    event message_reaction_remove_emoji, ReactionRemoveEmojiEvent

    # This event is fired when a user's presence updates in a guild. This also is fired when a user updates their name or avatar.
    #
    # https://discord.com/developers/docs/topics/gateway#presence-update
    event presence_update, PresenceUpdate

    # This event is fired when a user begins typing in a channel.
    #
    # https://discord.com/developers/docs/topics/gateway#typing-start
    event typing_start, TypingStart

    # This event is fired when properties of a User change.
    #
    # https://discord.com/developers/docs/topics/gateway#user-update
    event user_update, User, User?

    # This event is fired when a user's voice state changes.
    #
    # https://discord.com/developers/docs/topics/gateway#voice-state-update
    event voice_state_update, VoiceState, VoiceState?
end
