# frozen_string_literal: true

module Tamashii
  module Server
    # :nodoc:
    class Client
      class << self
        def register(socket)
          return false unless socket.is_a?(Connection::ClientSocket)
          clients.add(socket)
        end

        def unregister(socket)
          clients.delete(socket)
        end

        def clients
          @clients ||= Set.new
        end
      end
    end
  end
end
