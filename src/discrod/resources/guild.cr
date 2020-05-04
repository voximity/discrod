module Discrod
    enum VerificationLevel
        # No restrictions on verification.
        None

        # Must have a verified email on account.
        Low

        # Must be registered on Discord for longer than five minutes.
        Medium

        # Must be a member of the server for longer than ten minutes.
        High

        # Must have a verified phone number.
        VeryHigh
    end

    enum DefaultMessageNotifications
        AllMessages
        OnlyMentions
    end

    enum ExplicitContentFilter
        Disabled
        MembersWithoutRoles
        AllMembers
    end

    enum MFALevel
        None
        Elevated
    end

    @[Flags]
    enum SystemChannelFlags : Int64
        SuppressJoinNotifications = 1 << 0
        SuppressPremiumSubscriptions = 1 << 1
    end

    enum GuildPremiumTier
        None
        Tier1
        Tier2
        Tier3
    end

    class Guild
        include JSON::Serializable

        getter id : Snowflake
        getter name : String
        getter icon : String?
        getter splash : String?
        getter discovery_splash : String?
        getter owner : Bool?
        getter owner_id : Snowflake
        getter permissions : Permissions?
        getter region : String
        getter afk_channel_id : Snowflake?
        getter afk_timeout : Int32?
        getter embed_enabled : Bool?
        getter embed_channel_id : Snowflake?
        getter verification_level : VerificationLevel
        getter default_message_notifications : DefaultMessageNotifications
        getter explicit_content_filter : ExplicitContentFilter
        getter roles : Array(Role) = [] of Role
        getter emojis : Array(Emoji) = [] of GuildEmoji
        getter features : Array(String) = [] of String
        getter mfa_level : MFALevel
        getter application_id : Snowflake?
        getter widget_enabled : Bool?
        getter widget_channel_id : Snowflake?
        getter system_channel_id : Snowflake?
        getter system_channel_flags : SystemChannelFlags?
        getter rules_channel_id : Snowflake?
        getter joined_at : Time?
        getter large : Bool?
        getter unavailable : Bool?
        getter member_count : Int32?
        # getter voice_state : Array(VoiceState) = [] of VoiceState
        # getter members : Array(Member) = [] of Member
        getter channels : Array(GuildChannel) = [] of Discrod::GuildChannel
        # getter presences : Array(PresenceUpdate) = [] of PresenceUpdate
        getter max_presences : Int32?
        getter max_members : Int32?
        getter vanity_url_code : String?
        getter description : String?
        getter banner : String?
        getter premium_tier : GuildPremiumTier
        getter premium_subscription_count : Int32?
        getter preferred_locale : String?
        getter public_updates_channel_id : Snowflake?
        getter approximate_member_count : Int32?
        getter approximate_presence_count : Int32?
    end

    struct GuildEmoji
        include JSON::Serializable

        getter id : Snowflake
        getter name : String
        @[JSON::Field(key: "roles")]
        getter role_ids : Array(Snowflake)?
        getter user : User?
        getter require_colons : Bool?
        getter managed : Bool?
        getter animated : Bool?
        getter available : Bool?
    end

    class UnavailableGuild
        include JSON::Serializable

        getter id : Snowflake
        getter unavailable : Bool?
    end
end
