module Discrod::Resources
    @[Flags]
    enum ActivityFlags
        Instance = 1 << 0
        Join = 1 << 1
        Spectate = 1 << 2
        JoinRequest = 1 << 3
        Sync = 1 << 4
        Play = 1 << 5
    end

    struct ActivityTimestamps
        include JSON::Serializable

        @[JSON::Field(key: "start", converter: Time::EpochMillisConverter)]
        getter start_time : Time?
        @[JSON::Field(key: "end", converter: Time::EpochMillisConverter)]
        getter end_time : Time?
    end

    struct ActivityParty
        include JSON::Serializable

        getter id : String?
        getter size : Tuple(Int32, Int32)?
    end

    struct ActivityAssets
        include JSON::Serializable

        getter large_image : String?
        getter large_text : String?
        getter small_image : String?
        getter small_text : String?
    end

    struct ActivitySecrets
        include JSON::Serializable

        getter join : String?
        getter spectate : String?
        getter match : String?
    end

    struct Activity
        include JSON::Serializable

        getter name : String
        getter type : ActivityType
        getter url : String?
        @[JSON::Field(converter: Time::EpochMillisConverter)]
        getter created_at : Time
        getter timestamps : ActivityTimestamps?
        getter application_id : Snowflake?
        getter details : String?
        getter state : String?
        getter emoji : AbstractEmoji?
        getter party : ActivityParty?
        getter assets : ActivityAssets?
        getter secrets : ActivitySecrets?
        getter instance : Bool?
        getter flags : ActivityFlags?
    end

    struct ClientStatus
        include JSON::Serializable

        getter desktop : String?
        getter mobile : String?
        getter web : String?
    end

    struct PresenceUpdate
        include JSON::Serializable

        getter user : User
        @[JSON::Field(key: "roles")]
        getter role_ids : Array(Snowflake)
        getter game : Activity?
        getter guild_id : Snowflake
        getter status : String
        getter activities : Array(Activity)?
        getter client_status : ClientStatus
        getter premium_since : Time?
        getter nick : String?
    end
end