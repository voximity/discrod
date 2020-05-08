module Discrod::Resources
    # Represents the type of channel.
    enum ChannelType : Int32
        GuildText
        DirectMessage
        GuildVoice
        GroupDirectMessage
        GuildCategory
        GuildNews
        GuildStore
    end

    # Represents the type of permission overwrite.
    enum PermissionOverwriteType
        Role
        Member
    end

    # Represents the direction of snowflake search to be used. `SnowflakeDirection::Around` is only sometimes usable.
    enum SnowflakeDirection
        Around
        Before
        After
    end

    # Represents a permission overwrite, a structure that overrides permissions for a certain
    # role or user (depending on `PermissionOverwrite#type`).
    struct PermissionOverwrite
        include JSON::Serializable

        getter id : Snowflake
        
        @type : String

        getter allow : Permissions

        getter deny : Permissions

        def type
            return PermissionOverwriteType::Role if type == "role"
            return PermissionOverwriteType::Member if type == "member"
            raise "Invalid permission overwrite type"
        end

        def initialize(id : Snowflake | UInt64, type : PermissionOverwriteType, @allow : Permissions = Permissions::None, @deny : Permissions = Permissions::None)
            @id = Snowflake.new(id)
            @type = type.to_s.downcase
        end
    end

    # `MessageChannel` is a set of common endpoints between channels in which messages are sent.
    # This is intended to unify guild text channels and DM channels with common endpoints.
    # Meanwhile, `TextChannel` inherits `GuildChannel`, while `DirectMessageChannel` inherits `Channel`.
    # Therefore, any two classes including this module do not share an ancestor with this module.
    # You must evaluate the type of the channel at runtime.
    module MessageChannel
        # Get messages from this channel, given a `message_id` and a `SnowflakeDirection`.
        #
        # See `REST::Channel#get_channel_messages`.
        def get_messages(message_id : Snowflake, direction : SnowflakeDirection, limit : Int32 = 50, client : Client? = nil) : Array(Message)
            client ||= Discrod.client
            client.get_channel_messages(id, message_id, direction, limit)
        end

        # Get a message from this channel, given a `message_id`.
        #
        # See `REST::Channel#get_channel_message`.
        def get_message(message_id : Snowflake, client : Client? = nil)
            client ||= Discrod.client
            client.get_channel_message(id, message_id)
        end

        # Send a message to this channel.
        #
        # See `REST::Channel#create_message`.
        def create_message(
            content : String? = nil,
            nonce : String | Int32 | Nil = nil,
            tts : Bool? = nil,
            client : Client? = nil,
            embed : Embed? = nil
            # payload_json,
            # allowed_mentions
        ) : Message
            client ||= Discrod.client
            client.create_message(id, content: content, nonce: nonce, tts: tts, embed: embed)
        end

        # Begin typing in this channel.
        #
        # See `REST::Channel#trigger_typing_indicator`.
        def trigger_typing_indicator(client : Client? = nil)
            client ||= Discrod.client
            client.trigger_typing_indicator(id)
        end

        # Get pinned messages for this channel.
        #
        # See `REST::Channel#get_pinned_messages`.
        def get_pinned_messages(client : Client? = nil)
            client ||= Discrod.client
            client.get_pinned_messages(id)
        end

        # Pin a message to this channel by its ID.
        #
        # See `REST::Channel#add_pinned_channel_message`.
        def pin_message(message_id : Snowflake, client : Client? = nil)
            client ||= Discrod.client
            client.add_pinned_channel_message(id, message_id)
        end

        # Pin a message to this channel.
        #
        # See `REST::Channel#add_pinned_channel_message`.
        def pin_message(message : Message, client : Client? = nil)
            pin_message(message.id, client)
        end

        # Unpin a message from this channel by its ID.
        #
        # See `REST::Channel#delete_pinned_channel_message`.
        def unpin_message(message_id : Snowflake, client : Client? = nil)
            client ||= Discrod.client
            client.delete_pinned_channel_message(id, message_id)
        end

        # Unpin a message from this channel.
        #
        # See `REST::Channel#delete_pinned_channel_message`.
        def unpin_message(message : Message, client : Client? = nil)
            unpin_message(message.id, client)
        end
    end

    # A channel resource. This type, while not abstract, is used to umbrella other channel types. (See `Discrod::Resources::ChannelType`)
    class Channel
        include JSON::Serializable
        include MessageChannel # i hate this. i hate everything about this. i hate this so much.

        use_json_discriminator "type", {
            ChannelType::GuildText => TextChannel,
            ChannelType::DirectMessage => DirectMessageChannel,
            ChannelType::GuildVoice => VoiceChannel,
            ChannelType::GroupDirectMessage => DirectMessageChannel,
            ChannelType::GuildCategory => Category,
            ChannelType::GuildNews => TextChannel,
            ChannelType::GuildStore => TextChannel
        }

        # The ID of the channel, as a Snowflake.
        getter id : Snowflake

        # The type of channel.
        getter type : ChannelType

        # Delete this channel.
        def delete(client : Client? = nil)
            client ||= Discrod.client
            client.delete_channel(id)
        end
    end

    # A DM channel resource. Automatically discriminated when ordinary channels are deserialized.
    class DirectMessageChannel < Channel
        getter last_message_id : Snowflake
        getter recipients : Array(User)
        getter owner_id : Snowflake?
        getter application_id : Snowflake?
        getter last_pin_timestamp : Time?

        # GDM-specific endpoints are not implemented. are they necessary?
    end

    # A guild channel resource. Similar to `Channel`, umbrellas other guild channel types.
    class GuildChannel < Channel
        getter guild_id : Snowflake?
        getter position : Int32
        getter permission_overwrites : Array(PermissionOverwrite)
        getter name : String

        def guild(client : Client? = nil)
            client ||= Discrod.client
            client.guild_cache!.get!(guild_id)
        end

        def edit_permissions(
            overwrite : PermissionOverwrite,
            client : Client? = nil
        )
            client ||= Discrod.client
            client.edit_channel_permissions(id, overwrite)
        end

        def invites(client : Client? = nil) : Array(Invite)
            client ||= Discrod.client
            client.get_channel_invites(id)
        end

        def create_invite(
            max_age : Time::Span? = nil,
            max_uses : Int32 = 0,
            temporary : Bool = false,
            unique : Bool = false,
            client : Client? = nil
        ) : Invite
            client ||= Discrod.client
            client.create_channel_invite(id, max_age: max_age, max_uses: max_uses, temporary: temporary, unique: unique)
        end

        def delete_permission(
            overwrite_id : Snowflake | UInt64,
            client : Client? = nil
        )
            client ||= Discrod.client
            client.delete_channel_permission(id, overwrite_id)
        end
    end
    
    # A guild text channel. Automatically discriminated when deserialized.
    class TextChannel < GuildChannel
        getter topic : String?
        getter nsfw : Bool
        getter last_message_id : Snowflake?
        getter parent_id : Snowflake?
        getter last_pin_timestamp : Time?
    end

    # A guild category. Contains no discerning characteristics except for that other `GuildChannel`s can have
    # their `#parent_id` property set to this category's ID to reposition the channel. Automatically
    # discriminated when deserialized.
    class Category < GuildChannel
    end

    # A guild voice channel. Automaticaally discriminated when deserialized.
    class VoiceChannel < GuildChannel
        getter bitrate : Int32
        getter user_limit : Int32
        getter rate_limit_per_user : Int32
    end

    # A payload representing a channel pins update. Contains helper methods to invoke a client's cache.
    class ChannelPinsUpdate
        include JSON::Serializable

        # The guild ID containing the channel in question.
        getter guild_id : Snowflake?

        # The channel ID whose pins were updated.
        getter channel_id : Snowflake?

        # The most recent pin timestamp. Nil when a pin is removed.
        getter last_pin_timestamp : Time?

        # Derive a `Guild` from the `guild_id`. This does not test whether or not the channel is a `GuildChannel`, which
        # is your responsibility. Also expects caching to be enabled.
        def guild(client : Client? = nil)
            client ||= Discrod.client
            client.guild_cache!.get!(@guild_id)
        end

        # Derive a `Channel` from the `channel_id`. Expects caching to be enabled.
        def channel(client : Client? = nil)
            client ||= Discrod.client
            client.channel_cache!.get!(@guild_id)
        end
    end
end
