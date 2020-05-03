module Discrod
    enum TokenType
        Bot
        Bearer
    end

    class Client
        @web_socket : WS::WebSocket?

        getter token
        getter token_type

        def initialize(@token : String = "", @token_type : TokenType = TokenType::Bot)
            @web_socket = WS::WebSocket.new(self)
        end

        def connect
            @web_socket.try &.run
        end
    end
end
