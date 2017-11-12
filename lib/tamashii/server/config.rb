# frozen_string_literal: true

require 'tamashii/config'

module Tamashii
  module Server
    # :nodoc:
    class Config
      include Tamashii::Configurable

      config :connection_class, default: Connection::Base
      config :pubsub_class, default: Subscription::Redis
      config :log_path, default: STDOUT
    end
  end
end
