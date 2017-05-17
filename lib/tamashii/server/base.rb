# frozen_string_literal: true

module Tamashii
  module Server
    # :nodoc:
    class Base
      attr_reader :mutex

      def initialize
        @mutex = Monitor.new
        mutex.synchronize { @instance ||= Rack.new(self, event_loop) }
      end

      def call(env)
        @instance.call(env)
      end

      def pubsub
        @pubsub || mutex.synchronize do
          @pubsub ||= Server.config.pubsub_class.new(self)
        end
      end

      def event_loop
        @event_loop || mutex.synchronize do
          @event_loop ||= Connection::StreamEventLoop.new
        end
      end
    end
  end
end
