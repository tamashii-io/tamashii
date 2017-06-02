# frozen_string_literal: true

require 'tamashii/version'

module Tamashii
  module Server
    # :nodoc:
    class Response < ::Rack::Response
      def initialize(body = {}, status = 200, header = {}, &block)
        body = process_body(body)
        header = process_header(header, body.first)
        super
      end

      def process_body(body)
        [body.merge(version: Tamashii::VERSION).to_json]
      end

      def process_header(header, body)
        header.merge(
          'Content-Type' => 'application/json',
          'Content-Length' => body.bytesize
        )
      end
    end
  end
end
