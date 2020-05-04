require "http"
require "http/status"
require "http/web_socket"
require "json"
require "log"
require "uri"

# temporary patch to use_json_discriminator
require "./json_serialization_patch.cr"

require "./discrod/resources/channel.cr"
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
