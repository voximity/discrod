require "emoji"

module Discrod
    abstract struct AbstractEmoji
        abstract def to_s : String
    end

    struct Emoji < AbstractEmoji
        def initialize(@emoji : String)
        end

        def to_s : String
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

        def to_s : String
            @id.to_s
        end

        def initialize(
            @id,
            @name,
            @role_ids,
            @user,
            @require_colons,
            @managed,
            @animated,
            @available
        )
        end
    end

    struct PartialEmoji
        include JSON::Serializable

        getter id : Snowflake?
        getter name : String?
        @[JSON::Field(key: "roles")]
        getter role_ids : Array(Snowflake)?
        getter user : User?
        getter require_colons : Bool?
        getter managed : Bool?
        getter animated : Bool?
        getter available : Bool?

        def emoji : AbstractEmoji
            if id.nil?
                Emoji.new(@name)
            else
                GuildEmoji.new(
                    @id.not_nil!,
                    @name || "",
                    @role_ids,
                    @user,
                    @require_colons,
                    @managed,
                    @animated,
                    @available
                )
            end
        end
    end
end
