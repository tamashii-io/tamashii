# frozen_string_literal: true

module Tamashii
  module Server
    module Connection
      # :nodoc:
      class Stream
        attr_reader :event_loop

        def initialize(event_loop, socket)
          @event_loop = event_loop
          @socket = socket
          @stream_send = socket.env['stream.send']

          @rack_hijack_io = nil
          @write_lock = Mutex.new

          @write_head = nil
          @write_buffer = Queue.new
        end

        def each(&callback)
          @stream_send ||= callback
        end

        def close
          shutdown
          @socket.client_gone
        end

        def shutdown
          clean_rack_hijack
        end

        def write(data)
          return @stream_send.call(data) if @stream_send

          write_safe(data) if @write_lock.try_lock
          data.bytesize
        rescue EOFError, Errno::ECONNRESET
          @socket.client_gone
        end

        def flush_write_buffer
          # TODO: Implement this method likes ActionCable
        end

        def receive(data)
          @socket.parse(data)
        end

        def hijack_rack_socket
          return unless @socket.env['rack.hijack']

          @socket.env['rack.hijack'].call
          @rack_hijack_io = @socket.env['rack.hijack_io']

          @event_loop.attach(@rack_hijack_io, self)
        end

        private

        def write_safe(data)
          return unless @write_head.nil? && @write_buffer.empty?
          written = @rack_hijack_io.write_nonblock(data, exception: false)

          case written
          when :wait_writable then write_buffer(data)
          when data.bytesize then data.bytesize
          else
            write_head data.byteslice(written, data.bytesize)
          end
        ensure
          @write_lock.unlock
        end

        def write_buffer(data)
          @write_buffer << data
          @event_loop.writes_pending @rack_hijack_io
        end

        def write_head(head)
          @write_head = head
          @event_loop.writes_pending @rack_hijack_io
        end

        def clean_rack_hijack
          return unless @rack_hijack_io
          @event_loop.detach(@rack_hijack_io, self)
          @rack_hijack_io = nil
        end
      end
    end
  end
end
