module Discrod::WS
    enum Opcode
        Dispatch
        Heartbeat
        Identify
        StatusUpdate
        VoiceStateUpdate
        VoiceServerPing
        Resume
        Reconnect
        RequestGuildMembers
        InvalidSession
        Hello
        HeartbeatAck
    end

    class WebSocket
        @web_socket : HTTP::WebSocket

        @heartbeat_interval : UInt32 = 0
        @heartbeat_fiber : Fiber? = nil
        @heartbeat_acknowledged : Bool = true

        @last_sequence : Int32? = nil
        @session_id : String? = nil
        
        @should_resume = false
        property should_reconnect = true

        def initialize(@client : Client)
            @web_socket = HTTP::WebSocket.new(@client.gateway, "/?encoding=json&v=#{DISCORD_API_VERSION}", tls: true,
                headers: HTTP::Headers{"Authorization" => @client.authorization})
            
            @web_socket.on_message do |message|
                packet = Packet(JSON::Any).from_json(message)
                packet.s.try { |s| @last_sequence = s }

                case packet.op
                when Opcode::Dispatch
                    case packet.t
                    when "READY"
                        payload = Packet(ReadyPayload).from_json(message).payload
                        @session_id = payload.session_id
                        resume if @should_resume
                        @client.fire_ready

                    when "CHANNEL_CREATE"
                        channel = Packet(Channel).from_json(message).payload
                        @client.channel_cache.try &.<<(channel)
                        @client.fire_channel_create(channel)
                    when "CHANNEL_UPDATE"
                        channel = Packet(Channel).from_json(message).payload
                        @client.channel_cache.try &.<<(channel)
                        @client.fire_channel_update(channel)
                    when "CHANNEL_DELETE"
                        channel = Packet(Channel).from_json(message).payload
                        @client.channel_cache.try &.delete(channel)
                        @client.fire_channel_delete(channel)
                    when "CHANNEL_PINS_UPDATE"
                        @client.fire_channel_pins_update(Packet(ChannelPinsUpdate).from_json(message).payload)
                    when "GUILD_CREATE"
                        guild = Packet(Guild).from_json(message).payload
                        @client.guild_cache.try &.<<(guild)
                        @client.role_cache.try do |cache|
                            guild.roles.each { |role| cache << role }
                        end
                        @client.channel_cache.try do |cache|
                            guild.channels.each { |channel| cache << channel }
                        end
                        @client.fire_guild_create(guild)
                    when "GUILD_UPDATE"
                        guild = Packet(Guild).from_json(message).payload
                        @client.guild_cache.try &.<<(guild)
                        @client.fire_guild_update(guild)
                    when "GUILD_DELETE"
                        unavailable_guild = Packet(UnavailableGuild).from_json(message).payload
                        guild = @client.guild_cache.try { |cache| cache.get(unavailable_guild.id) }
                        @client.guild_cache.try &.delete(unavailable_guild.id)
                        @client.fire_guild_delete(guild)
                    when "GUILD_BAN_ADD"
                        ban = Packet(GuildBanPayload).from_json(message).payload
                        @client.fire_guild_ban_add(ban.user, @client.guild_cache.try &.get(ban.guild_id))
                    when "GUILD_EMOJIS_UPDATE"
                        emojis = Packet(GuildEmojisUpdatePayload).from_json(message).payload
                        @client.fire_guild_emojis_update(emojis.emojis, @client.guild_cache.try &.get(emojis.guild_id))
                    when "GUILD_INTEGRATIONS_UPDATE"
                        payload = Packet(GuildIntegrationsUpdatePayload).from_json(message).payload
                        @client.fire_guild_integrations_update(@client.guild_cache.try &.get(payload.guild_id))
                    when "GUILD_MEMBER_ADD"
                        member = Packet(Member).from_json(message).payload
                        guild = member.guild_id.try { |id| @client.guild_cache.try &.get(id) }
                        @client.fire_guild_member_add(member, guild)
                    when "GUILD_MEMBER_UPDATE"
                        member_update = Packet(MemberUpdate).from_json(message).payload
                        guild = @client.guild_cache.try &.get(member_update.guild_id)
                        @client.fire_guild_member_update(member_update, guild)
                    when "GUILD_MEMBER_REMOVE"
                        payload = Packet(GuildMemberRemovePayload).from_json(message).payload
                        guild = @client.guild_cache.try &.get(payload.guild_id)
                        @client.fire_guild_member_remove(payload.user, guild)
                    # when "GUILD_MEMBERS_CHUNK"
                    when "GUILD_ROLE_CREATE"
                        payload = Packet(GuildRolePayload).from_json(message).payload
                        guild = @client.guild_cache.try &.get(payload.guild_id)
                        @client.role_cache.try &.<<(payload.role)
                        @client.fire_guild_role_create(payload.role, guild)
                    when "GUILD_ROLE_UPDATE"
                        payload = Packet(GuildRolePayload).from_json(message).payload
                        guild = @client.guild_cache.try &.get(payload.guild_id)
                        @client.role_cache.try &.<<(payload.role)
                        @client.fire_guild_role_update(payload.role, guild)
                    when "GUILD_ROLE_DELETE"
                        payload = Packet(GuildRoleRemovePayload).from_json(message).payload
                        role = @client.role_cache.try &.get(payload.role_id)
                        guild = @client.guild_cache.try &.get(payload.guild_id)
                        @client.role_cache.try &.delete(payload.role_id)
                        @client.fire_guild_role_delete(role, guild)
                    when "INVITE_CREATE"
                        invite = Packet(Invite).from_json(message).payload
                        guild = invite.guild_id.try { |id| @client.guild_cache.try &.get(id) }
                        channel = @client.channel_cache.try &.get(invite.channel_id)
                        @client.fire_invite_create(invite, channel, guild)
                    when "INVITE_DELETE"
                        deletion = Packet(DeletedInvite).from_json(message).payload
                        guild = deletion.guild_id.try { |id| @client.guild_cache.try &.get(id) }
                        channel = @client.channel_cache.try &.get(deletion.channel_id)
                        @client.fire_invite_delete(deletion.code, channel, guild)
                    when "MESSAGE_CREATE"
                        @client.fire_message_create(Packet(Message).from_json(message).payload)
                    when "MESSAGE_UPDATE"
                        @client.fire_message_update(Packet(Message).from_json(message).payload)
                    when "MESSAGE_DELETE"
                        deletion = Packet(MessageRemovePayload).from_json(message).payload
                        guild = deletion.guild_id.try { |id| @client.guild_cache.try &.get(id) }
                        channel = @client.channel_cache.try &.get(deletion.channel_id)
                        @client.fire_message_delete(deletion.id, channel, guild)
                    when "MESSAGE_DELETE_BULK"
                        deletion = Packet(MessageBulkRemovePayload).from_json(message).payload
                        guild = deletion.guild_id.try { |id| @client.guild_cache.try &.get(id) }
                        channel = @client.channel_cache.try &.get(deletion.channel_id)
                        @client.fire_message_delete_bulk(deletion.ids, channel, guild)
                    when "MESSAGE_REACTION_ADD"
                        @client.fire_message_reaction_add(Packet(ReactionEvent).from_json(message).payload)
                    when "MESSAGE_REACTION_REMOVE"
                        @client.fire_message_reaction_remove(Packet(ReactionEvent).from_json(message).payload)
                    when "MESSAGE_REACTION_REMOVE_ALL"
                        deletion = Packet(ReactionRemoveAllPayload).from_json(message).payload
                        guild = deletion.guild_id.try { |id| @client.guild_cache.try &.get(id) }
                        channel = @client.channel_cache.try &.get(deletion.channel_id)
                        @client.fire_message_reaction_remove_all(deletion.message_id, channel, guild)
                    when "MESSAGE_REACTION_REMOVE_EMOJI"
                        @client.fire_message_reaction_remove_emoji(Packet(ReactionRemoveEmojiEvent).from_json(message).payload)
                    when "PRESENCE_UPDATE"
                        @client.fire_presence_update(Packet(PresenceUpdate).from_json(message).payload)
                    when "TYPING_START"
                        @client.fire_typing_start(Packet(TypingStart).from_json(message).payload)
                    when "USER_UPDATE"
                    when "VOICE_STATE_UPDATE"
                    when "VOICE_SERVER_UPDATE"
                    when "WEBHOOKS_UPDATE"
                    else
                        puts packet.t
                    end
                when Opcode::Hello
                    # Deserialize the payload to determine the heartbeat interval.
                    payload = Packet(HelloPayload).from_json(message).payload

                    # Set the heartbeat interval.
                    @heartbeat_interval = payload.heartbeat_interval

                    # Begin heartbeating.
                    begin_heartbeat

                    # Send identify.
                    send_identify
                when Opcode::Reconnect
                    reconnect(should_resume: Packet(Bool).from_json(message).payload)
                when Opcode::HeartbeatAck
                    @heartbeat_acknowledged = true
                else
                    puts packet.op
                end
            end

            @web_socket.on_close do |code, a|
                Discrod.log.warn { "Gateway closed with code #{GatewayClose.new(code.value)}." }
                next unless @should_reconnect
                case GatewayClose.new(code.value)
                when GatewayClose::UnknownError
                    reconnect
                when GatewayClose::InvalidSequence
                    reconnect(should_resume: false)
                when GatewayClose::RateLimited
                    reconnect
                when GatewayClose::SessionTimedOut
                    reconnect(should_resume: false)
                else
                    raise GatewayCloseException.new GatewayClose.new(code.value)
                end
            end
        end

        def reconnect(should_resume : Bool = true)
            Discrod.log.info { "Attempting to reconnect to the gateway..." }
            @web_socket.close unless @web_socket.closed?
            @should_resume = should_resume
            @heartbeat_acknowledged = true
            run
        end

        def close
            @web_socket.close
        end

        def run
            @web_socket.run
        end

        def send(packet : Packet(T)) forall T
            @web_socket.send(packet.to_json)
        end

        def send_identify
            payload = IdentifyPayload.new(token: @client.token)
            packet = Packet(IdentifyPayload).new(Opcode::Identify, d: payload)
            send packet
        end

        def begin_heartbeat
            @heartbeat_fiber = spawn do
                loop do
                    sleep @heartbeat_interval.milliseconds
                    unless @heartbeat_acknowledged
                        Discrod.log.warn { "Heartbeat was not acknowledged!" }
                        reconnect
                        break
                    end
                    send_heartbeat
                end
            end
        end

        def send_heartbeat
            packet = Packet(Int32?).new(Opcode::Heartbeat, d: @last_sequence)
            @heartbeat_acknowledged = false
            send packet
        end

        def resume
            payload = ResumePayload.new(token: @client.token, session_id: @session_id.not_nil!, seq: @last_sequence)
            packet = Packet(ResumePayload).new(Opcode::Resume, d: payload)
            send packet
            @should_resume = false
        end
    end
end
