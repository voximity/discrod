module Discrod::REST::Guild
    # TODO: add create guild

    # Gets a guild from Discord's API, skipping the cache. Use the cache to get guilds if you do not wish to request the API.
    #
    # https://discord.com/developers/docs/resources/guild#get-guild
    def get_guild(id : Id) : Guild
        body = @route_client.get Route.new "/guilds/#{id.to_s}"
        Guild.from_json body
    end

    # Gets a `GuildPreview` from a guild's ID. Only available for public guilds.
    #
    # https://discord.com/developers/docs/resources/guild#get-guild-preview
    def get_guild_preview(id : Id) : GuildPreview
        GuildPreview.from_json @route_client.get Route.new("/guilds/#{id.to_s}/preview")
    end

    # Modify guild. Add later

    # Deletes a guild. Only available for bots in under ten guilds.
    #
    # https://discord.com/developers/docs/resources/guild#delete-guild
    def delete_guild(id : Id)
        @route_client.delete Route.new("/guilds/#{id.to_s}")
    end

    # Gets a list of guild channels.
    #
    # https://discord.com/developers/docs/resources/guild#get-guild-channels
    def get_guild_channels(id : Id) : Array(GuildChannel)
        Array(GuildChannel).from_json @route_client.get Route.new("/guilds/#{id.to_s}/channels")
    end

    # Creates a guild channel.
    #
    # https://discord.com/developers/docs/resources/guild#get-guild-channels
    def create_guild_channel(
        guild_id : Id,
        name : String,
        channel_type : ChannelType,
        topic : String? = nil,
        bitrate : Int32? = nil,
        user_limit : Int32? = nil,
        slow_mode_seconds : Int32? = nil,
        position : Int32? = nil,
        permission_overwrites : Array(PermissionOverwrite)? = nil,
        parent_id : Id? = nil,
        nsfw : Bool? = nil
    ) : GuildChannel
        # 0, 2, 4, 5, and 6 are the valid values for ChannelType
        raise "channel type #{channel_type} is not available to guild channel creation" unless [0, 2, 4, 5, 6].includes?(channel_type.value)

        form = {
            "name" => name,
            "type" => channel_type,
            "topic" => topic,
            "bitrate" => bitrate,
            "user_limit" => user_limit,
            "rate_limit_per_user" => slow_mode_seconds,
            "position" => position,
            "permission_overwrites" => permission_overwrites,
            "parent_id" => parent_id,
            "nsfw" => nsfw
        }

        GuildChannel.from_json @route_client.post Route.new("/guilds/#{guild_id.to_s}/channels"), form.to_json
    end

    # Modifies the position of a list of guild channels. Takes an array of `Tuple(Snowflake | UInt64, Int32)` to reorganize.
    #
    # https://discord.com/developers/docs/resources/guild#modify-guild-channel-positions
    def modify_guild_channel_positions(
        guild_id : Id,
        positions : Array(Tuple(Id, Int32))
    )
        form = positions.map { |id, position| {"id" => id.to_s, position => position} }
        @route_client.patch Route.new("/guilds/#{guild_id.to_s}/channels"), form.to_json
    end

    # Gets a guild member from a user ID.
    #
    # https://discord.com/developers/docs/resources/guild#get-guild-member
    def get_guild_member(
        guild_id : Id,
        user_id : Id
    ) : Member
        Member.from_json @route_client.get Route.new("/guilds/#{guild_id.to_s}/members/#{user_id.to_s}")
    end

    # Lists guild members, given a limit and an ID to start from. See the docs from Discord below:
    #
    # https://discord.com/developers/docs/resources/guild#list-guild-members
    def list_guild_members(
        guild_id : Id,
        limit : Int32 = 1,
        after : Id = 0
    ) : Array(Member)
        Array(Member).from_json @route_client.get Route.new("/guilds/#{guild_id.to_s}/members"), {"limit" => limit, "after" => after}
    end

    # Add guild member: necessary for bots?

    # TODO: more of this
end