# frozen_string_literal: true

Thread.abort_on_exception = true

module Tamashii
  module Server
    module Connection
      # :nodoc:
      class StreamEventLoop
        def initialize
          @nio = @thread = nil
          @stopping = false

          @streams = {}

          @todo = Queue.new

          @spawn_mutex = Mutex.new
        end

        def attach(io, stream)
          @todo << lambda do
            @streams[io] = @nio.register(io, :r)
            @streams[io].value = stream
          end
          wakeup
        end

        def detach(io, _)
          @streams << lambda do
            @nio.deregister io
            @streams.delete io
            io.close
          end
          wakeup
        end

        def writes_pending(io)
          @todo << lambda do
            monitor = @streams[io]
            monitor.interesets = :rw if monitor
          end
          wakeup
        end

        def stop
          @stopping = true
          wakeup if @nio
        end

        def stopped?
          @stopping
        end

        private

        def spawn
          return if @thread && @thread.status

          @spawn_mutex.synchronize do
            return if @thread && @thread.status

            @nio ||= NIO::Selector.new
            @thread = Thread.new { run }

            return true
          end
        end

        def wakeup
          spawn || @nio.wakeup
        end

        def run
          loop do
            if stopped?
              @nio.close
              break
            end

            @todo.pop(true).call until @todo.empty?

            monitors = @nio.select
            next unless monitors
            process(monitors)
          end
        end

        def process(monitors)
          monitors.each do |monitor|
            io = monitor.io
            stream = monitor.value

            if monitor.writable?
              monitor.interests = :r if stream.flush_write_buffer
              next unless monitor.readable?
            end

            next unless read(io, stream)
          end
        end

        def read(io, stream)
          incoming = io.read_nonblock(4096, exception: false)
          case incoming
          when :wait_readable then false
          when nil then stream.close
          else
            stream.receive incoming
          end
        rescue
          try_close(io, stream)
        end

        def try_close(io, stream)
          stream.close
        rescue
          @nio.deregister io
          @streams.delete io
        end
      end
    end
  end
end
