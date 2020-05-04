module Discrod::WS
    GATEWAY = "gateway.discord.gg"

    enum Encoding
        Json
        Etf
    end

    enum GatewayClose
        UnknownError         = 4000
        UnknownOpcode        = 4001
        DecodeError          = 4002
        NotAuthenticated     = 4003
        AuthenticationFailed = 4004
        AlreadyAuthenticated = 4005
        InvalidSequence      = 4007
        RateLimited          = 4008
        SessionTimedOut      = 4009
        InvalidShard         = 4010
        ShardingRequired     = 4011
        InvalidApiVersion    = 4012
        InvalidIntents       = 4013
        DisallowedIntents    = 4014
    end

    class GatewayCloseException < Exception
        def initialize(@code : GatewayClose)
        end

        def message
            "The gateway closed with code #{@code.value}: #{@code}"
        end
    end

    struct ShardPair
        getter shard_id : Int64
        getter shard_count : Int64

        def self.new(pull : JSON::PullParser)
            shard_id : Int64
            shard_count : Int64
            
            pull.read_begin_array
            shard_id = pull.read_int
            shard_count = pull.read_int
            pull.read_end_array

            new(shard_id, shard_count)
        end

        def initialize(@shard_id, @shard_count)
        end

        def to_json(builder : JSON::Builder)
            builder.start_array
            builder.number @shard_id
            builder.number @shard_count
            builder.end_array
        end
    end

    struct IdentifyProperties
        JSON.mapping(
            os: {key: "$os", type: String},
            browser: {key: "$browser", type: String},
            device: {key: "$device", type: String}
        )

        def initialize(@os = "linux", @browser = "discrod", @device = "discrod")
        end
    end

    struct HelloPayload
        JSON.mapping(
            heartbeat_interval: UInt32
        )
    end

    struct IdentifyPayload
        JSON.mapping(
            token: String,
            properties: IdentifyProperties,
            compress: Bool?,
            large_threshold: UInt32?,
            shard: ShardPair?,
            guild_subscriptions: Bool?,
            intents: Intents?
        )

        def initialize(
            @token,
            @properties = IdentifyProperties.new,
            @compress = nil,
            @large_threshold = nil,
            @shard = nil,
            @guild_subscriptions = nil,
            @intents = nil
        )
        end
    end

    struct ReadyPayload
        JSON.mapping(
            v: Int32,
            user: User,
            session_id: String,
            shard: ShardPair?
        )
    end

    struct ResumePayload
        JSON.mapping(
            token: String,
            session_id: String,
            seq: Int32?
        )

        def initialize(@token : String, @session_id : String, @seq : Int32?)
        end
    end

    struct GuildBanPayload
        include JSON::Serializable

        getter guild_id : Snowflake
        getter user : User
    end

    struct GuildEmojisUpdatePayload
        include JSON::Serializable

        getter guild_id : Snowflake
        getter emojis : Array(GuildEmoji)
    end

    struct GuildIntegrationsUpdatePayload
        JSON.mapping(
            guild_id: Snowflake
        )
    end

    struct GuildMemberRemovePayload
        JSON.mapping(
            guild_id: Snowflake,
            user: User
        )
    end

    struct GuildRolePayload
        JSON.mapping(
            guild_id: Snowflake,
            role: Role
        )
    end

    struct GuildRoleRemovePayload
        JSON.mapping(
            guild_id: Snowflake,
            role_id: Snowflake
        )
    end
end
