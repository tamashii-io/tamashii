# frozen_string_literal: true

require 'json'
require 'websocket/driver'
require 'rack'
require 'nio'
require 'thread'
require 'redis'

require 'tamashii/server/rack'
require 'tamashii/server/response'
require 'tamashii/server/client'

require 'tamashii/server/connection/client_socket'
require 'tamashii/server/connection/stream_event_loop'
require 'tamashii/server/connection/stream'

require 'tamashii/server/subscription/redis'

module Tamashii
  # :nodoc:
  module Server
    LOCK = Monitor.new

    class << self
      attr_reader :instance

      def compile
        @instance ||= Rack.new
      end

      def call(env)
        LOCK.synchronize { compile } unless instance
        call!(env)
      end

      def call!(env)
        instance.call(env)
      end

      def broadcast(payload)
        pubsub.broadcast(payload)
      end

      def subscribe
        pubsub.subscribe
      end

      private

      def pubsub
        @pubsub || LOCK.synchronize do
          @pubsub ||= Subscription::Redis.new
        end
      end
    end
  end
end
