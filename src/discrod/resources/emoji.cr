require "emoji"

module Discrod
    abstract struct AbstractEmoji
        abstract def to_s : String
    end

    struct Emoji < AbstractEmoji
        def initialize(@emoji : String)
        end

        def to_s
            ::Emoji.emojize @emoji
        end
    end

    struct GuildEmoji < AbstractEmoji
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

        def to_s
            @id.to_s
        end
    end
end
