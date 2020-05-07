module Discrod::REST::EmojiEndpoints
    # Gets guild emoji from the API.
    #
    # https://discord.com/developers/docs/resources/emoji#get-guild-emoji
    def get_guild_emoji(guild_id : Snowflake | UIn64, emoji_id : Id)
        GuildEmoji.from_json @route_client.get Route.new "/guilds/#{guild_id.to_s}/emojis/#{emoji_id.to_s}"
    end

    # Creates a guild emoji.
    #
    # https://discord.com/developers/docs/resources/emoji#create-guild-emoji
    def create_guild_emoji(
        guild_id : Id,
        name : String,
        image_file : String,
        image_content_type : String = "jpeg"#,
        #role_ids
    ) : GuildEmoji
        form = {
            "name" => name,
            "image" => "data:image/#{image_content_type};base64,#{Base64.encode(image_file)}"
        }
        GuildEmoji.from_json @route_client.post Route.new("/guilds/#{guild_id.to_s}"), form
    end

    # Modifies a guild emoji.
    #
    # https://discord.com/developers/docs/resources/emoji#modify-guild-emoji
    def modify_guild_emoji(
        guild_id : Id,
        emoji_id : Id,
        name : String? = nil
    )
        form = {
            "name" => name
        }
        @route_client.patch Route.new("/guilds/#{guild_id.to_s}/emojis/#{emoji_id.to_s}"), form
    end

    # Deletes a guild emoji.
    #
    # https://discord.com/developers/docs/resources/emoji#delete-guild-emoji
    def delete_guild_emoji(
        guild_id : Id,
        emoji_id : Id
    )
        @route_client.delete Route.new("/guilds/#{guild_id.to_s}/emojis/#{emoji_id.to_s}")
    end
end
