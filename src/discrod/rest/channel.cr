module Discrod::REST::Channel
    # Gets a channel from Discord's API, skipping the cache. Use the cache to get channels if you do not wish to request the API.
    #
    # https://discordapp.com/developers/docs/resources/channel#get-channel
    def get_channel(id : Id) : Channel
        body = @route_client.get Route.new "/channels/#{id.to_s}"
        Channel.from_json body
    end

    # Modify channel

    # Deletes a channel.
    #
    # https://discordapp.com/developers/docs/resources/channel#deleteclose-channel
    def delete_channel(id : Id)
        @route_client.delete Route.new "/channels/#{id.to_s}"
    end

    # Gets an `Array(Message)` based on the search criteria given.
    #
    # https://discordapp.com/developers/docs/resources/channel#get-channel-messages
    def get_channel_messages(channel_id : Id, message_id : Id, direction : SnowflakeDirection, limit : Int32 = 50) : Array(Message)
        query = {} of String => String | Int32
        query["limit"] = limit
        query[direction.to_s.downcase] = message_id.to_s
        Array(Message).from_json @route_client.get Route.new "/channels/#{channel_id}/messages?#{query.map { |k, v| "#{k}=#{v}" }.join "&"}"
    end

    # Gets a message from a channel.
    #
    # https://discordapp.com/developers/docs/resources/channel#get-channel-message
    def get_channel_message(channel_id : Id, message_id : Id) : Message
        Message.from_json @route_client.get Route.new "/channels/#{channel_id.to_s}/messages/#{message_id.to_s}"
    end

    # Creates a message in a channel.
    #
    # https://discordapp.com/developers/docs/resources/channel#create-message
    def create_message(
        channel_id : Id,
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
        channel_id : Id,
        message_id : Id,
        emoji : AbstractEmoji
    )
        @route_client.put Route.new("/channels/#{channel_id.to_s}/messages/#{message_id.to_s}/reactions/#{URI.encode emoji.to_s}/@me")
    end

    # Remove a reaction from a message. Pass nil for `user_id` to specify yourself.
    #
    # https://discordapp.com/developers/docs/resources/channel#create-reaction
    def delete_reaction(
        channel_id : Id,
        message_id : Id,
        emoji : AbstractEmoji,
        user_id : (Id)? = nil
    )
        @route_client.delete Route.new("/channels/#{channel_id.to_s}/messages/#{message_id.to_s}/reactions/#{URI.encode emoji.to_s}/#{(user_id || "@me").to_s}")
    end

    # Get reactions from a message. Has a hard limit of 100 users per request. `SnowflakeDirection::Around` is not valid here and will throw an error.
    #
    # https://discordapp.com/developers/docs/resources/channel#get-reactions
    def get_reactions(
        channel_id : Id,
        message_id : Id,
        emoji : AbstractEmoji,
        limit : Int32 = 25,
        user_id : (Id)? = nil,
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
        channel_id : Id,
        message_id : Id
    )
        @route_client.delete Route.new "/channels/#{channel_id.to_s}/messages/#{message_id.to_s}/reactions"
    end

    # Deletes all reactions from a message matching a specific emoji.
    #
    # https://discordapp.com/developers/docs/resources/channel#delete-all-reactions-for-emoji
    def delete_all_reactions_for_emoji(
        channel_id : Id,
        message_id : Id,
        emoji : AbstractEmoji
    )
        @route_client.delete Route.new "/channels/#{channel_id.to_s}/messages/#{message_id.to_s}/reactions/#{URI.encode emoji.to_s}"
    end

    # Bulk delete messages. Requires an array of snowflake IDs.
    # This method will not work on messages older than two weeks.
    #
    # https://discordapp.com/developers/docs/resources/channel#bulk-delete-messages
    def bulk_delete_messages(
        channel_id : Id,
        message_ids : Array(Id)
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
        channel_id : Id,
        overwrite : PermissionOverwrite
    )
        @route_client.put Route.new("/channels/#{channel_id.to_s}/permissions/#{overwrite.id.to_s}"), overwrite.to_json
    end

    # Get an `Array(Invite)` for a channel.
    #
    # https://discordapp.com/developers/docs/resources/channel#get-channel-invites
    def get_channel_invites(
        channel_id : Id
    ) : Array(Invite)
        Array(Invite).from_json @route_client.get Route.new "/channels/#{channel_id.to_s}/invites"
    end

    # Creates an `Invite` for a channel. Pass `max_age: Time::Span.zero` to set infinite lifetime.
    #
    # https://discordapp.com/developers/docs/resources/channel#create-channel-invite
    def create_channel_invite(
        channel_id : Id,
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
        channel_id : Id,
        overwrite_id : Id
    )
        @route_client.delete Route.new("/channels/#{channel_id.to_s}/permissions/#{overwrite_id.to_s}")
    end

    # Triggers the typing indicator in a channel. The indicator ends after five seconds or the next message sent, whichever comes first.
    #
    # https://discordapp.com/developers/docs/resources/channel#trigger-typing-indicator
    def trigger_typing_indicator(
        channel_id : Id
    )
        @route_client.post Route.new("/channels/#{channel_id.to_s}/typing")
    end

    # Gets an `Array(Message)` representing a channel's pins.
    #
    # https://discordapp.com/developers/docs/resources/channel#get-pinned-messages
    def get_pinned_messages(
        channel_id : Id
    ) : Array(Message)
        Array(Message).from_json @route_client.get Route.new("/channels/#{channel_id.to_s}/pins")
    end

    # Adds a message to a channel's pins. A hard cap of 50 pinned messages is present for all channels.
    #
    # https://discordapp.com/developers/docs/resources/channel#add-pinned-channel-message
    def add_pinned_channel_message(
        channel_id : Id,
        message_id : Id
    )
        @route_client.put Route.new("/channels/#{channel_id.to_s}/pins/#{message_id.to_s}")
    end

    # Removes a message from a channel's pins.
    #
    # https://discordapp.com/developers/docs/resources/channel#delete-pinned-channel-message
    def delete_pinned_channel_message(
        channel_id : Id,
        message_id : Id
    )
        @route_client.delete Route.new("/channels/#{channel_id.to_s}/pins/#{message_id.to_s}")
    end
end