require "emoji"

module Discrod::Resources
    # An abstract emoji. Parent class for `Emoji` and `GuildEmoji`.
    abstract struct AbstractEmoji
        abstract def to_s : String
    end

    # An emoji. Can be instantiated with `Discrod::Emoji.new ":confetti_ball:"`.
    struct Emoji < AbstractEmoji
        def initialize(@emoji : String)
        end

        def to_s : String
            ::Emoji.emojize @emoji
        end
    end

    # A guild emoji.
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

    # A partial emoji. Does not implement `AbstractEmoji`, but an
    # `AbstractEmoji` can be fetched using `PartialEmoji#emoji`.
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

        # Create an `AbstractEmoji` from this `PartialEmoji` based on the presence
        # of the `id` field.
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
