require "http"
require "http/web_socket"
require "json"
require "uri"

require "./discrod/resources/user.cr"

require "./discrod/ws/gateway.cr"
require "./discrod/ws/intents.cr"
require "./discrod/ws/packet.cr"
require "./discrod/ws/ws.cr"

require "./discrod/client.cr"
require "./discrod/route.cr"
require "./discrod/snowflake.cr"
