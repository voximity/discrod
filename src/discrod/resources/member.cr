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

        protected def guild_id=(id : Snowflake?)
            @guild_id = id
        end

        def guild(client : Client? = nil)
            client ||= Discrod.client
            client.guild_cache!.get!(guild_id.not_nil!)
        end

        def roles(client : Client? = nil)
            role_ids.map { |id| guild.roles.find { |role| role.id == id }.not_nil! }.sort { |a, b| a.position <=> b.position }
        end
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

    struct VoiceState
        include JSON::Serializable

        getter guild_id : Snowflake?
        getter channel_id : Snowflake?
        getter user_id : Snowflake?
        getter member : Member?
        getter session_id : String?
        getter deaf : Bool
        getter mute : Bool
        getter self_deaf : Bool
        getter self_mute : Bool

        # why is it called self_stream... are we going to allow servers to force members to go live in the future?
        # discord API questionable

        @[JSON::Field(key: "self_stream")]
        getter stream : Bool?
        getter suppress : Bool
    end
end
