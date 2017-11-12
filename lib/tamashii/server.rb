# frozen_string_literal: true

require 'json'
require 'logger'
require 'logger/colors'
require 'websocket/driver'
require 'rack'
require 'nio'
require 'concurrent'
require 'redis'

require 'tamashii/hookable'

module Tamashii
  # :nodoc:
  module Server
    autoload :Rack,         'tamashii/server/rack'
    autoload :Base,         'tamashii/server/base'
    autoload :Response,     'tamashii/server/response'
    autoload :Client,       'tamashii/server/client'
    autoload :Connection,   'tamashii/server/connection'
    autoload :Subscription, 'tamashii/server/subscription'
    autoload :Config,       'tamashii/server/config'

    def self.config(&block)
      @config ||= Config.new
      return instance_exec(@config, &block) if block_given?
      @config
    end

    def self.logger
      # TODO: Add config to set logger path
      @logger ||= ::Logger.new(config.log_path)
    end
  end
end

Tamashii::Hook.after(:config) do |config|
  config.register(:server, Tamashii::Server.config)
end
