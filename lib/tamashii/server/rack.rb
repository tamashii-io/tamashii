# frozen_string_literal: true

module Tamashii
  module Server
    # :nodoc:
    class Rack
      def initialize(server, event_loop)
        @server = server
        @event_loop = event_loop
      end

      def call(env)
        return start_websocket(env) if ::WebSocket::Driver.websocket?(env)
        start_http(env)
      end

      private

      def start_websocket(env)
        conn = Server.config.connection_class.new(@server, env, @event_loop)
        conn.init
      end

      def start_http(_)
        # TODO: Supply API for query WebSocket status
        Server::Response.new(message: 'Invalid protocol or api endpoint')
      end
    end
  end
end
