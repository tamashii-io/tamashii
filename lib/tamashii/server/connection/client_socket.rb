# frozen_string_literal: true

module Tamashii
  module Server
    module Connection
      # :nodoc:
      class ClientSocket
        def self.determine_url(env)
          scheme = secure_request?(env) ? 'wss:' : 'ws:'
          "#{scheme}//#{env['HTTP_HOST']}#{env['REQUEST_URI']}"
        end

        def self.secure_request?(env)
          return true if env['HTTPS'] == 'on'
          return true if env['HTTP_X_FORWARDED_SSL'] == 'on'
          return true if env['HTTP_X_FORWARDED_SCHEME'] == 'https'
          return true if env['HTTP_X_FORWARDED_PROTO'] == 'https'
          return true if env['rack.url_scheme'] == 'https'

          false
        end

        attr_reader :env, :url
        attr_accessor :id

        # TODO: Support define protocols
        def initialize(server, env, event_loop)
          @server = server
          @env = env
          @event_loop = event_loop

          @id ||= env['REMOTE_ADDR']

          @url = ClientSocket.determine_url(@env)
          @driver = setup_driver

          @stream = Stream.new(@event_loop, self)
        end

        def start_driver
          return if @driver.nil?
          @stream.hijack_rack_socket

          callback = @env['async.callback']
          callback&.call([101, {}, @stream])

          @driver.start
        end

        def rack_response
          start_driver
          Server.logger.info("Accept new websocket connection from #{env['REMOTE_ADDR']}")
          Server::Response.new(message: 'WebSocket Connected')
        end

        def write(data)
          @stream.write(data)
        rescue => e
          emit_error e.message
        end

        def transmit(message)
          Server.logger.debug("Send to #{id} with data #{message}")
          case message
          when Numeric then @driver.text(message.to_s)
          when String then @driver.text(message)
          else
            @driver.binary(message)
          end
        end

        def close
          # TODO: Define close reason / code
          @driver.close('', 1000)
        end

        def parse(data)
          @driver.parse(data)
        end

        def client_gone
          finialize_close
        end

        def protocol
          @driver.protocol
        end

        private

        def setup_driver
          driver = ::WebSocket::Driver.rack(self)

          driver.on(:open) { |_| open }
          driver.on(:message) { |e| receive_message(e.data) }
          driver.on(:close) { |e| begin_close(e.reason, e.code) }
          driver.on(:error) { |e| emit_error(e.message) }

          driver
        end

        def open
          Server::Client.register(self)
        end

        def receive_message(data)
          @server.pubsub.broadcast(data)
        end

        def emit_error(message)
          Server.logger.error("Client #{id} has some error: #{message}")
        end

        def begin_close(_reason, _code)
          Server.logger.info("Close connection to #{id}")
          Client.unregister(self)
          finialize_close
        end

        def finialize_close
          # TODO: Processing close
          @stream.close
        end
      end
    end
  end
end
