# frozen_string_literal: true

require 'json'
require 'websocket/driver'
require 'rack'
require 'nio'
require 'thread'
require 'redis'

module Tamashii
  # :nodoc:
  module Server
    autoload :Rack,         'tamashii/server/rack'
    autoload :Base,         'tamashii/server/base'
    autoload :Response,     'tamashii/server/response'
    autoload :Client,       'tamashii/server/client'
    autoload :Connection,   'tamashii/server/connection'
    autoload :Subscription, 'tamashii/server/subscription'

    # TODO: Move below code to base
    LOCK = Monitor.new

    class << self
      attr_reader :instance

      def compile
        @instance ||= Rack.new(event_loop)
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

      def event_loop
        @event_loop || Server::LOCK.synchronize do
          @event_loop ||= Connection::StreamEventLoop.new
        end
      end
    end
  end
end
