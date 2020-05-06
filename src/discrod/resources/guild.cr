module Discrod::Resources
    # The verification level for a server.
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

    # The default setting for message notifications on a server.
    enum DefaultMessageNotifications
        AllMessages
        OnlyMentions
    end

    # The explicit content filter for a server.
    enum ExplicitContentFilter
        Disabled
        MembersWithoutRoles
        AllMembers
    end

    # The MFA level in place on a server.
    enum MFALevel
        None
        Elevated
    end

    # Settings for a server's system channel.
    @[Flags]
    enum SystemChannelFlags : Int64
        SuppressJoinNotifications = 1 << 0
        SuppressPremiumSubscriptions = 1 << 1
    end

    # The Nitro boost tier of a server.
    enum GuildPremiumTier
        None
        Tier1
        Tier2
        Tier3
    end

    # A guild resource. See [Discord's API](https://discordapp.com/developers/docs/resources/guild) for more information.
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
        getter emojis : Array(GuildEmoji) = [] of Discrod::GuildEmoji
        getter features : Array(String) = [] of String
        getter roles : Array(Role) = [] of Discrod::Role
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
        getter approximate_member_count : UInt32?
        getter approximate_presence_count : UInt32?
    end

    # An unavailable guild. Acts as a wrapper for an `id` and `unavailable` field.
    class UnavailableGuild
        include JSON::Serializable

        getter id : Snowflake
        getter unavailable : Bool?
    end

    # A guild preview. Only available for public guilds.
    class GuildPreview
        include JSON::Serializable

        getter id : Snowflake
        getter name : String
        getter icon : String?
        getter splash : String?
        getter discovery_splash : String?
        getter emojis : Array(GuildEmoji)?
        getter features : Array(String)?
        getter approximate_member_count : UInt32?
        getter approximate_presence_count : UInt32?
        getter description : String?
    end
end
