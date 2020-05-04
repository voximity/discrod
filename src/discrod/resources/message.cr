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
    end
end