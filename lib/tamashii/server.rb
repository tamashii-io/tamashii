# frozen_string_literal: true

require 'json'
require 'logger'
require 'logger/colors'
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

    def self.logger
      # TODO: Add config to set logger path
      @logger ||= ::Logger.new(STDOUT)
    end
  end
end
