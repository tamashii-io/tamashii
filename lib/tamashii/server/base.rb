# frozen_string_literal: true

module Tamashii
  module Server
    # :nodoc:
    class Base
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
end
