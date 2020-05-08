module Discrod
    EPOCH = 1420070400000_u64
    
    # An identifier for a unique resource.
    # https://discordapp.com/developers/docs/reference#snowflakes
    struct Snowflake
        include Comparable(UInt64)
        include Comparable(String)

        property value

        def self.new(snowflake : Snowflake)
            snowflake
        end

        def self.new(value : String)
            new(value.to_u64)
        end

        def self.new(pull : JSON::PullParser)
            new(pull.read_string)
        end

        def initialize(@value : UInt64)
        end

        def to_json(builder : JSON::Builder)
            value.to_s.to_json(builder)
        end

        def timestamp
            Time.unix_ms((@value >> 22) + EPOCH)
        end

        def internal_worker
            (@value & 0x3E0000) >> 17
        end

        def internal_process
            (@value & 0x1F000) >> 12
        end

        def process_increment
            @value & 0xFFF
        end

        def <=>(uint : UInt64)
            @value <=> uint
        end

        def <=>(string : String)
            @value <=> string.to_u64?
        end

        def to_s
            @value.to_s
        end

        def to_i64
            @value.to_i64
        end
    end
end
