module Discrod::WS
    GATEWAY = "gateway.discord.gg"

    enum Encoding
        Json
        Etf
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
end
