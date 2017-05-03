# frozen_string_literal: true

require 'json'
require 'websocket/driver'
require 'rack'
require 'nio'
require 'thread'

require 'tamashii/server/rack'
require 'tamashii/server/response'

require 'tamashii/server/connection/client_socket'
require 'tamashii/server/connection/stream_event_loop'
require 'tamashii/server/connection/stream'

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
    end
  end
end
