module Discrod
    enum ChannelType : Int32
        GuildText
        DirectMessage
        GuildVoice
        GroupDirectMessage
        GuildCategory
        GuildNews
        GuildStore
    end

    enum PermissionOverwriteType
        Role
        Member
    end

    enum SnowflakeDirection
        Around
        Before
        After
    end

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

    class Channel
        include JSON::Serializable

        use_json_discriminator "type", {
            ChannelType::GuildText => TextChannel,
            ChannelType::DirectMessage => DirectMessageChannel,
            ChannelType::GuildVoice => VoiceChannel,
            ChannelType::GroupDirectMessage => DirectMessageChannel,
            ChannelType::GuildCategory => Category,
            ChannelType::GuildNews => TextChannel,
            ChannelType::GuildStore => TextChannel
        }

        getter id : Snowflake
        getter type : ChannelType

        def delete(client : Client? = nil)
            client ||= Discrod.client
            client.delete_channel(id)
        end

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

        def get_messages(message_id : Snowflake, direction : SnowflakeDirection, limit : Int32 = 50, client : Client? = nil) : Array(Message)
            client ||= Discrod.client
            client.get_channel_messages(id, message_id, direction, limit)
        end

        def get_message(message_id : Snowflake, client : Client? = nil)
            client ||= Discrod.client
            client.get_channel_message(id, message_id)
        end
    end

    class DirectMessageChannel < Channel
        getter last_message_id : Snowflake
        getter recipients : Array(User)
        getter owner_id : Snowflake?
        getter application_id : Snowflake?
        getter last_pin_timestamp : Time?
    end

    class GuildChannel < Channel
        getter guild_id : Snowflake?
        getter position : Int32
        getter permission_overwrites : Array(PermissionOverwrite)
        getter name : String

        def guild(client : Client? = nil)
            client ||= Discrod.client
            client.guild_cache!.get!(guild_id)
        end
    end
    
    class TextChannel < GuildChannel
        getter topic : String?
        getter nsfw : Bool
        getter last_message_id : Snowflake?
        getter parent_id : Snowflake?
        getter last_pin_timestamp : Time?
    end

    class Category < GuildChannel
    end

    class VoiceChannel < GuildChannel
        getter bitrate : Int32
        getter user_limit : Int32
        getter rate_limit_per_user : Int32
    end

    class ChannelPinsUpdate
        include JSON::Serializable

        getter guild_id : Snowflake?
        getter channel_id : Snowflake?
        getter last_pin_timestamp : Time?
    end
end
