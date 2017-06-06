# frozen_string_literal: true

module Tamashii
  module Server
    module Subscription
      # :nodoc:
      class Redis
        def initialize(server)
          @server = server
        end

        def broadcast(payload)
          Server.logger.info("Broadcasting: #{payload}")
          broadcast_conn.publish('_tamashii_internal', pack(payload))
        end

        def subscribe
          ensure_listener_running
        end

        def shutdown
          subscription_conn.unsubscribe
        end

        def prepare
          ensure_listener_running
        end

        def pack(data)
          case data
          when Numeric then "N:#{data}"
          when String then "S:#{data}"
          else
            "B:#{data.pack('C*')}"
          end
        end

        def unpack(data)
          case data[0..1]
          when 'N:' then data[2..-1].to_i
          when 'S:' then data[2..-1]
          else
            data[2..-1].unpack('C*')
          end
        end

        protected

        def broadcast_conn
          # TODO: Add config to support set server
          @conn || @server.mutex.synchronize do
            @conn ||= ::Redis.new
          end
        end

        def subscription_conn
          @subscription_conn ||= ::Redis.new
        end

        def listen
          Server.logger.info('Starting subscribe redis #_tamashii_internal channel')
          subscription_conn.without_reconnect do
            # TODO: Add config to support set namespace
            subscription_conn.subscribe('_tamashii_internal') do |on|
              on.message { |_, message| process_message(message) }
            end
          end
        end

        def process_message(message)
          Client.clients.dup.each { |client| client.transmit(unpack(message)) }
        end

        def ensure_listener_running
          @thread ||= Thread.new { listen }
        end
      end
    end
  end
end
