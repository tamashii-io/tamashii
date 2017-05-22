# frozen_string_literal: true

require 'tamashii/configurable'

module Tamashii
  module Server
    # :nodoc:
    class Config
      include Tamashii::Configurable

      register :connection_class, Connection::Base
      register :pubsub_class, Subscription::Redis
    end
  end
end
