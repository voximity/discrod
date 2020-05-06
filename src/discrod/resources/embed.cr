module Discrod::Resources
    EMBED_TITLE_MAX = 256
    EMBED_DESCRIPTION_MAX = 2048
    EMBED_FIELD_MAX = 25
    EMBED_FIELD_NAME_MAX = 256
    EMBED_FIELD_VALUE_MAX = 1024
    EMBED_FOOTER_MAX = 2048
    EMBED_AUTHOR_MAX = 256
    EMBED_GENERAL_MAX = 6000

    # An exception that is thrown when an `EmbedBuilder` attempts to build an embed that has
    # one or more properties that exceed Discord's limits on embed text.
    class EmbedLimitException < Exception
    end

    # An embed builder. Use like:
    # ```
    # builder = Discrod::EmbedBuilder.new do |e|
    #   e.with_title "Embed title"
    #   e.with_description "Embed description"
    #   e.with_url "https://github.com/voximity/discrod"
    #   e.with_time Time.utc
    #   # ... 
    # end
    # 
    # embed = builder.build
    # ```
    class EmbedBuilder
        getter title : String?
        def with_title(@title : String?)
        end

        getter type : String? = "rich"

        getter description : String?
        def with_description(@description : String?)
        end

        getter url : String?
        def with_url(@url : String?)
        end

        getter timestamp : Time?
        def with_time(@timestamp : Time?)
        end
        def with_current_time
            @timestamp = Time.utc
        end

        getter color : Int32?
        def with_color(@color : Int32?)
        end

        getter footer : EmbedFooter?
        def with_footer(text : String, url : String? = nil)
            @footer = EmbedFooter.new(text, url)
        end

        getter image : EmbedImage?
        def with_image(url : String?)
            @image = EmbedImage.new(url)
        end

        getter thumbnail : EmbedThumbnail?
        def with_thumbnail(url : String?)
            @thumbnail = EmbedThumbnail.new(url)
        end

        # getter video : EmbedVideo?
        # getter provider : EmbedProvider?
        getter author : EmbedAuthor?
        def with_author(name : String?, url : String? = nil, icon_url : String? = nil)
            @author = EmbedAuthor.new(name: name, url: url, icon_url: icon_url)
        end
        def with_author(user : User)
            with_author(name: "#{user.username}##{user.discriminator}", icon_url: user.avatar_url)
        end

        getter fields : Array(EmbedField)?
        def add_field(name : String, value : String, inline : Bool? = nil)
            (@fields ||= [] of Discrod::EmbedField) << EmbedField.new(name, value, inline)
        end

        def self.new
            builder = new
            yield builder
            builder
        end

        def initialize
        end

        def build
            # These enforcements are made as per https://discordapp.com/developers/docs/resources/channel#embed-limits
            @title.try { |title| raise EmbedLimitException.new "Embed field 'title' exceeds character limit of #{EMBED_TITLE_MAX}" unless (0..EMBED_TITLE_MAX).includes?(title.size) }
            @description.try { |description| raise EmbedLimitException.new "Embed field 'description' exceeds character limit of #{EMBED_DESCRIPTION_MAX}" unless (0..EMBED_DESCRIPTION_MAX).includes?(description.size) }
            @fields.try do |fields|
                raise EmbedLimitException.new "Number of Embed fields exceed limit of #{EMBED_FIELD_MAX}" unless (0..EMBED_FIELD_MAX).includes?(fields.size)
                fields.each do |field|
                    raise EmbedLimitException.new "One of Embed fields exceeds name character limit of #{EMBED_FIELD_NAME_MAX}" unless (0..EMBED_FIELD_NAME_MAX).includes?(field.name.size)
                    raise EmbedLimitException.new "One of Embed fields exceeds value character limit of #{EMBED_FIELD_VALUE_MAX}" unless (0..EMBED_FIELD_VALUE_MAX).includes?(field.value.size)
                end
            end
            @footer.try { |footer| raise EmbedLimitException.new "Embed footer field 'text' exceeds character limit of #{EMBED_FOOTER_MAX}" unless (0..EMBED_FOOTER_MAX).includes?(footer.text.size) }
            @author.try { |author| raise EmbedLimitException.new "Embed author field 'name' exceeds character limit of #{EMBED_AUTHOR_MAX}" unless (0..EMBED_AUTHOR_MAX).includes?(author.name.size) }

            Embed.new(
                title: @title,
                type: @type,
                description: @description,
                url: @url,
                timestamp: @timestamp,
                color: @color,
                footer: @footer,
                image: @image,
                thumbnail: @thumbnail,
                author: @author,
                fields: @fields,
                video: nil,
                provider: nil
            )
        end
    end

    struct Embed
        include JSON::Serializable

        getter title : String?
        getter type : String? = "rich"
        getter description : String?
        getter url : String?
        getter timestamp : Time?
        getter color : Int32?
        getter footer : EmbedFooter?
        getter image : EmbedImage?
        getter thumbnail : EmbedThumbnail?
        getter video : EmbedVideo?
        getter provider : EmbedProvider?
        getter author : EmbedAuthor?
        getter fields : Array(EmbedField)?

        def initialize(
            @title : String? = nil,
            @type : String? = "rich",
            @description : String? = nil,
            @url : String? = nil,
            @timestamp : Time? = nil,
            @color : Int32? = nil,
            @footer : EmbedFooter? = nil,
            @image : EmbedImage? = nil,
            @thumbnail : EmbedThumbnail? = nil,
            @video : EmbedVideo? = nil,
            @provider : EmbedProvider? = nil,
            @author : EmbedAuthor? = nil,
            @fields : Array(EmbedField)? = nil
        )
        end
    end

    struct EmbedFooter
        include JSON::Serializable

        property text : String
        property icon_url : String?
        getter proxy_icon_url : String?

        def initialize(@text : String)
        end
    end

    struct EmbedImage
        include JSON::Serializable

        property url : String?
        getter proxy_url : String?
        getter width : Int32?
        getter height : Int32?
        
        def initialize(@url : String?)
        end
    end

    struct EmbedThumbnail
        include JSON::Serializable

        property url : String?
        getter proxy_url : String?
        getter height : Int32?
        getter width : Int32?

        def initialize(@url : String?)
        end
    end

    struct EmbedVideo
        include JSON::Serializable

        property url : String?
        getter height : Int32?
        getter width : Int32?

        def initialize(@url : String?)
        end
    end

    struct EmbedProvider
        include JSON::Serializable

        property name : String?
        property url : String?

        def initialize(@name : String?, url : String?)
        end
    end

    struct EmbedAuthor
        include JSON::Serializable

        property name : String?
        property url : String?
        property icon_url : String?
        getter proxy_icon_url : String?

        def initialize(@name : String?, @url : String? = nil, @icon_url : String? = nil)
        end
    end

    struct EmbedField
        include JSON::Serializable

        property name : String
        property value : String
        property inline : Bool?

        def initialize(@name : String, @value : String, @inline : Bool? = nil)
        end
    end
end
