# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Tamashii::Server do
  let :env do
    {
      'REQUEST_METHOD'             => 'GET',
      'HTTP_CONNECTION'            => 'Upgrade',
      'HTTP_UPGRADE'               => 'websocket',
      'HTTP_ORIGIN'                => 'http://www.example.com',
      'HTTP_SEC_WEBSOCKET_KEY'     => 'JFBCWHksyIpXV+6Wlq/9pw==',
      'HTTP_SEC_WEBSOCKET_VERSION' => '13',
    }
  end

  let(:client) { double(Tamashii::Manager::Client) }
  let(:event_loop) {
    obj = double(Tamashii::Manager::StreamEventLoop)
    allow(obj).to receive(:timer)
    obj
  }

  before do
    # Prevent start thread
    expect(Tamashii::Manager::StreamEventLoop).to receive(:new).and_return(event_loop)
  end

  it 'starts http request' do
    request = Rack::MockRequest.env_for('/')
    response = subject.call(request)
    expect(response).to be_instance_of(Array)
  end

  it 'starts websocket request' do
    request = Rack::MockRequest.env_for('/', env)
    expect(Tamashii::Manager::Client).to receive(:new).with(request, event_loop).and_return(client)
    subject.call(request)
  end

  it 'only create one instance' do
    request = Rack::MockRequest.env_for('/')
    described_class.call(request)
    instance = described_class.instance
    described_class.call(request)
    expect(described_class.instance).to eq(instance)
  end
end
