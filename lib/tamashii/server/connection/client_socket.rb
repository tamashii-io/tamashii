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

        CONNECTING = 0
        OPEN       = 1
        CLOSING    = 2
        CLOSED     = 3

        attr_reader :env, :url
        attr_accessor :id

        # TODO: Support define protocols
        def initialize(server, conn, env, event_loop)
          @server = server
          @conn = conn
          @env = env
          @event_loop = event_loop

          @id ||= env['REMOTE_ADDR']
          @state = CONNECTING

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
          return unless @state == CONNECTING
          @state = OPEN
          @conn.on_open
          Client.register(self)
        end

        def receive_message(data)
          return unless @state == OPEN
          @conn.on_message(data)
        end

        def emit_error(message)
          return if @state >= CLOSING
          Server.logger.error("Client #{id} has some error: #{message}")
          @conn.on_error(message)
        end

        def begin_close(_reason, _code)
          # TODO: Define reason and code
          return if @state == CLOSED
          @state = CLOSING

          Server.logger.info("Close connection to #{id}")
          @conn.on_close
          Client.unregister(self)
          finialize_close
        end

        def finialize_close
          return if @state == CLOSED
          @state = CLOSED

          @stream.close
        end
      end
    end
  end
end
