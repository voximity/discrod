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

    enum UserPremiumType
        None
        NitroClassic
        Nitro
    end

    class User
        include JSON::Serializable

        getter id : Snowflake
        getter username : String
        getter discriminator : String
        getter avatar : String?
        getter bot : Bool?
        getter system : Bool?
        getter mfa_enabled : Bool?
        getter locale : String?
        getter verified : Bool?
        getter email : String?
        getter flags : UserFlags?
        getter premium_type : UserPremiumType?
        getter public_Flags : UserFlags?
    end
end
