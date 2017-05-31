# frozen_string_literal: true

require 'spec_helper'

RSpec::Matchers.define :detemine_as_secure_request do |env|
  match do
    Tamashii::Server::Connection::ClientSocket.secure_request?(env)
  end
end

RSpec::Matchers.define :use_secure_url do |env|
  match do
    Tamashii::Server::Connection::ClientSocket.determine_url(env).start_with?('wss://')
  end
end

RSpec.describe Tamashii::Server::Connection::ClientSocket do
  context 'ClassMethods' do
    subject { nil }
    describe '#determine_url' do
      it { should use_secure_url('HTTPS' => 'on') }
      it { should_not use_secure_url('HTTPS' => 'off') }
    end

    describe '#secure_request?' do
      it { should detemine_as_secure_request('HTTPS' => 'on') }
      it { should detemine_as_secure_request('HTTP_X_FORWARDED_SSL' => 'on') }
      it { should detemine_as_secure_request('HTTP_X_FORWARDED_SCHEME' => 'https') }
      it { should detemine_as_secure_request('HTTP_X_FORWARDED_PROTO' => 'https') }
      it { should detemine_as_secure_request('rack.url_scheme' => 'https') }
      it { should_not detemine_as_secure_request('OTHERS' => 'ENV') }
    end
  end

  let :env do
    {
      'REQUEST_METHOD'             => 'GET',
      'HTTP_CONNECTION'            => 'Upgrade',
      'HTTP_UPGRADE'               => 'websocket',
      'HTTP_ORIGIN'                => 'http://www.example.com',
      'HTTP_SEC_WEBSOCKET_KEY'     => key,
      'HTTP_SEC_WEBSOCKET_VERSION' => '13',
      'REMOTE_ADDR'                => '127.0.0.1',
      'rack.hijack'                => proc {},
      'rack.hijack_io'             => tcp_socket
    }
  end

  let(:request) { Rack::MockRequest.env_for('/', env) }
  let(:server) { double(Tamashii::Server::Base) }
  let(:tcp_socket) { double(TCPSocket) }
  let(:event_loop) { double(Tamashii::Server::Connection::StreamEventLoop) }
  let(:conn) { double(Tamashii::Server::Connection::Base) }
  let(:pubsub) { double(Tamashii::Server::Subscription::Redis) }
  let(:key) { '2vBVWg4Qyk3ZoM/5d3QD9Q==' }

  subject { Tamashii::Server::Connection::ClientSocket.new(server, conn, env, event_loop) }

  before do
    allow(conn).to receive(:on_open)
    allow(event_loop).to receive(:attach)
    allow(server).to receive(:pubsub).and_return(pubsub)
    allow(pubsub).to receive(:subscribe)
    allow(tcp_socket).to receive(:write_nonblock) do |message|
      @bytes = message.bytes.to_a
      @bytes.size
    end
  end

  describe '#rack_response' do
    it { expect(subject.rack_response).to be_instance_of(Tamashii::Server::Response) }
  end
end
