module Discrod
    class Message
        include JSON::Serializable

        getter id : Snowflake
        getter channel_id : Snowflake
        getter guild_id : Snowflake?
        getter author : User
        # member
        getter content : String
        getter timestamp : Time
        getter edited_timestamp : Time?
        # todo: finish

        def channel(client : Client? = nil)
            client ||= Discrod.client
            client.channel_cache!.get!(channel_id)
        end

        def react(emoji : AbstractEmoji, client : Client? = nil)
            client ||= Discrod.client
            client.create_reaction(channel_id, id, emoji)
        end
    end
end
