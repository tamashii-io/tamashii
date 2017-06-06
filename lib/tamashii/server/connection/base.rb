# frozen_string_literal: true

module Tamashii
  module Server
    module Connection
      # :nodoc:
      class Base
        def initialize(server, env, event_loop)
          @server = server
          @env = env
          @event_loop = event_loop

          @socket = nil
        end

        def init
          @socket = ClientSocket.new(@server, self, @env, @event_loop)
          @socket.rack_response
        end

        def on_open; end

        def on_message(data)
          @server.pubsub.broadcast(data)
        end

        def on_error(message = nil); end

        def on_close; end
      end
    end
  end
end
