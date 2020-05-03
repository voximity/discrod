module Discrod
    class Message
        JSON.mapping(
            id: Snowflake,
            channel_id: Snowflake,
            guild_id: Snowflake?,
            author: User,
            # member,
            content: String,
            timestamp: Time,
            edited_timestamp: Time?,
            # todo: finish
        )
    end
end