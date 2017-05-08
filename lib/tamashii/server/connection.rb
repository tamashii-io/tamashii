# frozen_string_literal: true

module Tamashii
  module Server
    # :nodoc:
    module Connection
      autoload :ClientSocket,    'tamashii/server/connection/client_socket'
      autoload :StreamEventLoop, 'tamashii/server/connection/stream_event_loop'
      autoload :Stream,          'tamashii/server/connection/stream'
    end
  end
end
