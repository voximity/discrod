module Discrod::WS
    class WebSocket
        @web_socket : HTTP::WebSocket
        @heartbeat_interval : UInt32 = 0
        @heartbeat_fiber : Fiber? = nil
        @last_sequence : Int32? = nil

        def initialize(@client : Client)
            @web_socket = HTTP::WebSocket.new(WS::GATEWAY, "/?encoding=json&v=6", tls: true,
                headers: HTTP::Headers{"Authorization" => "#{@client.token_type.to_s} #{@client.token}"})
            
            @web_socket.on_message do |message|
                packet = Packet(JSON::Any).from_json(message)
                packet.s.try { |s| @last_sequence = s }

                case packet.op
                when 0
                    # Opcode 0 Dispatch
                    case packet.t
                    when "READY"
                        payload = Packet(ReadyPayload).from_json(message).payload
                        puts payload.user.username
                    else
                    end
                when 10
                    # Opcode 10 Hello

                    # Deserialize the payload to determine the heartbeat interval.
                    payload = Packet(HelloPayload).from_json(message).payload

                    # Set the heartbeat interval.
                    @heartbeat_interval = payload.heartbeat_interval

                    # Begin heartbeating.
                    begin_heartbeat

                    # Send identify.
                    send_identify
                else
                end
            end
        end

        def run
            @web_socket.run
        end

        def send_identify
            payload = IdentifyPayload.new(token: @client.token)
            packet = Packet(IdentifyPayload).new(2, d: payload)
            @web_socket.send(packet.to_json)
        end

        def begin_heartbeat
            @hearbeat_fiber = Fiber.new do
                loop do
                    send_heartbeat
                    sleep @heartbeat_interval.milliseconds
                end
            end
        end

        def send_heartbeat
            packet = Packet(Int32?).new(1, d: @last_sequence)
            @web_socket.send(packet.to_json)
        end
    end
end