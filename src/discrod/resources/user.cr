module Discrod
    @[Flags]
    enum UserFlags : Int64
        DiscordEmployee      = 1 << 0
        DiscordPartner       = 1 << 1
        HypeSquad            = 1 << 2
        BugHunterLevelOne    = 1 << 3
        HouseBravery         = 1 << 6
        HouseBrilliance      = 1 << 7
        HouseBalance         = 1 << 8
        EarlySupporter       = 1 << 9
        TeamUser             = 1 << 10
        System               = 1 << 12
        BugHunterLevelTwo    = 1 << 14
        VerifiedBot          = 1 << 16
        VerifiedBotDeveloper = 1 << 17
    end

    enum PremiumType
        None
        NitroClassic
        Nitro
    end

    class User
        JSON.mapping(
            id: Snowflake,
            username: String,
            discriminator: String,
            avatar: String?,
            bot: Bool?,
            system: Bool?,
            mfa_enabled: Bool?,
            locale: String?,
            verified: Bool?,
            email: String?,
            flags: UserFlags?,
            premium_type: PremiumType?,
            public_flags: UserFlags?
        )
    end
end