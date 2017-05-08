# frozen_string_literal: true

module Tamashii
  module Server
    # :nodoc:
    class Rack
      def initialize(event_loop)
        @event_loop = event_loop
        Server.subscribe
      end

      def call(env)
        return start_websocket(env) if ::WebSocket::Driver.websocket?(env)
        start_http(env)
      end

      private

      def start_websocket(env)
        Connection::ClientSocket.new(env, @event_loop).rack_response
      end

      def start_http(_)
        # TODO: Supply API for query WebSocket status
        Server::Response.new(message: 'Invalid protocol or api endpoint')
      end
    end
  end
end
