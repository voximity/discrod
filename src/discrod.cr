require "http"
require "http/status"
require "http/web_socket"
require "json"
require "log"
require "uri"

# temporary patch to use_json_discriminator
require "./json_serialization_patch.cr"

module Discrod
    # This module constitutes classes & structs related to Discord resources.
    # Resources that support method invocation search for a client as set
    # by `Discrod.client`. This value is set when you instantiate a `Discrod::Client`
    # automatically, but you can optionally pass the `client` parameter to any
    # resource method to override the global `client`.
    #
    # For example:
    # ```
    # require "discrod"
    # client_a = Discrod::Client.new token: "my-token-a"
    # client_b = Discrod::Client.new token: "my-token-b"
    # 
    # client_a.on_message_create do |message|
    #   message.channel.create_message(content: "intercept from other client!", client: client_b)
    # end
    # 
    # client_a.connect
    # client_b.connect
    # ```
    module Resources
    end

    include Discrod::Resources
end

require "./discrod/resources/channel.cr"
require "./discrod/resources/embed.cr"
require "./discrod/resources/emoji.cr"
require "./discrod/resources/guild.cr"
require "./discrod/resources/invite.cr"
require "./discrod/resources/member.cr"
require "./discrod/resources/message.cr"
require "./discrod/resources/role.cr"
require "./discrod/resources/user.cr"

require "./discrod/ws/intents.cr"
require "./discrod/ws/packet.cr"
require "./discrod/ws/payloads.cr"
require "./discrod/ws/ws.cr"

require "./discrod/cache.cr"
require "./discrod/client.cr"
require "./discrod/permissions.cr"
require "./discrod/route.cr"
require "./discrod/snowflake.cr"