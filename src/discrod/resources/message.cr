module Discrod
    struct MessageCreatePayload
        include JSON::Serializable

        getter content : String?
        getter nonce : (Int32 | String)?
        getter tts : Bool?
        # file
        getter embed : Embed?
        # payload_json
        # allowed_mentions

        def initialize(@content = nil, @nonce = nil, @tts = nil, @embed = nil)
        end
    end

    class Message
        include JSON::Serializable

        getter id : Snowflake
        getter channel_id : Snowflake
        getter guild_id : Snowflake?
        getter author : User?
        # member
        getter content : String?
        getter timestamp : Time?
        getter edited_timestamp : Time?
        getter embed : Embed?
        # todo: finish

        def channel(client : Client? = nil)
            client ||= Discrod.client
            client.channel_cache!.get!(channel_id)
        end

        def react(emoji : AbstractEmoji, client : Client? = nil)
            client ||= Discrod.client
            client.create_reaction(channel_id, id, emoji)
        end

        def delete_reaction(emoji : AbstractEmoji, user_id : (Snowflake | UInt64)? = nil, client : Client? = nil)
            client ||= Discrod.client
            client.delete_reaction(channel_id, id, emoji, user_id)
        end

        def delete_reaction(emoji : AbstractEmoji, user : User? = nil, client : Client? = nil)
            delete_reaction(emoji, user.try &.id, client)
        end

        def get_reactions(emoji : AbstractEmoji, limit : Int32 = 25, user_id : (Snowflake | UInt64)? = nil, direction : SnowflakeDirection? = nil, client : Client? = nil)
            client ||= Discrod.client
            client.get_reactions(channel_id, id, emoji, limit: limit, user_id: user_id, direction: direction)
        end

        def delete_all_reactions(client : Client? = nil)
            client ||= Discrod.client
            client.delete_all_reactions(channel_id, id)
        end

        def delete_all_reactions_for_emoji(emoji : AbstractEmoji, client : Client? = nil)
            client ||= Discrod.client
            client.delete_all_reactions_for_emoji(channel_id, id, emoji)
        end
    end

    struct ReactionEvent
        include JSON::Serializable

        getter user_id : Snowflake
        getter channel_id : Snowflake
        getter message_id : Snowflake
        getter guild_id : Snowflake?
        getter member : Member?
        @emoji : PartialEmoji

        def emoji
            @emoji.emoji
        end

        def channel(client : Client? = nil)
            client ||= Discrod.client
            client.channel_cache!.get!(channel_id)
        end

        def guild(client : Client? = nil)
            client ||= Discrod.client
            client.guild_cache!.get!(guild_id.not_nil!)
        end
    end
end
