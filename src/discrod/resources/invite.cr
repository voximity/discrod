module Discrod
    struct Invite
        include JSON::Serializable

        getter channel_id : Snowflake
        getter code : String
        getter created_at : Time
        getter guild_id : Snowflake?
        getter inviter : User?
        @max_age : Int32
        getter max_uses : Int32
        # target_user
        # target_user_type
        getter temporary : Bool
        getter uses : Int32

        def max_age
            @max_age.seconds
        end
    end

    struct DeletedInvite
        include JSON::Serializable

        getter channel_id : Snowflake
        getter guild_id : Snowflake?
        getter code : String
    end
end
