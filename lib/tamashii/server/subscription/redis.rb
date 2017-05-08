# frozen_string_literal: true

module Tamashii
  module Server
    module Subscription
      # :nodoc:
      class Redis
        def initialize
          ensure_listener_running
        end

        def broadcast(payload)
          broadcast_conn.publish('_tamashii_internal', payload)
        end

        def shutdown
          subscription_conn.unsubscribe
        end

        def prepare
          ensure_listener_running
        end

        protected

        def broadcast_conn
          # TODO: Add config to support set server
          @conn || Server::LOCK.synchronize do
            @conn ||= ::Redis.new
          end
        end

        def subscription_conn
          @subscription_conn ||= ::Redis.new
        end

        def listen
          subscription_conn.without_reconnect do
            # TODO: Add config to support set namespace
            subscription_conn.subscribe('_tamashii_internal') do |on|
              on.message { |_, message| process_message(message) }
            end
          end
        end

        def process_message(message)
          Client.clients.each { |client| client.transmit(message) }
        end

        def ensure_listener_running
          @thread ||= Thread.new { listen }
        end
      end
    end
  end
end
