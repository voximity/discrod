module Discrod::WS
    alias GenericPayload = JSON::Any

    struct Packet(T)
        include JSON::Serializable

        # The opcode of the packet.
        getter op : Opcode
        
        # The sequence number. Valid in resumes/heartbeats.
        getter s : Int32?

        # The event name.
        getter t : String?

        # The payload.
        getter d : T

        # The payload.
        def payload
            @d
        end

        def initialize(@op, @d : T, @s : Int32? = nil, @t : String? = nil)
        end
    end
end
