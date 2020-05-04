module Discrod::Resources
    class Member
        include JSON::Serializable

        getter user : User?
        getter nick : String?
        @[JSON::Field(key: "roles")]
        getter role_ids : Array(Snowflake)
        getter joined_at : Time
        getter premium_since : Time?
        getter deaf : Bool
        getter mute : Bool
        getter guild_id : Snowflake?
    end

    class MemberUpdate
        include JSON::Serializable

        getter guild_id : Snowflake
        @[JSON::Field(key: "roles")]
        getter role_ids : Array(Snowflake)
        getter user : User
        getter nick : String?
        getter premium_since : Time?
    end
end
