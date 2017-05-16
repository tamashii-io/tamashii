require 'spec_helper'

RSpec.describe Tamashii::Server::Connection::StreamEventLoop do
  let(:nio) { instance_double(NIO::Selector) }
  let(:tcp_socket) { instance_double(TCPSocket) }
  let(:stream) { instance_double(Tamashii::Server::Connection::Stream) }
  let(:monitor) { instance_double(NIO::Monitor) }

  context "mocked thread" do
    before do
      allow(NIO::Selector).to receive(:new).and_return(nio)
      allow(Thread).to receive(:new) { |&block| block.call }

      allow(nio).to receive(:select).and_return([monitor])
      allow(nio).to receive(:wakeup)
      allow(nio).to receive(:close)

      allow(monitor).to receive(:value=).with(stream).and_return(stream)
      allow(monitor).to receive(:value).and_return(stream)
      allow(monitor).to receive(:io).and_return(tcp_socket)
      allow(monitor).to receive(:writable?).and_return(true)
      allow(monitor).to receive(:readable?).and_return(true)

      allow(tcp_socket).to receive(:read_nonblock).with(4096, exception: false).and_return([])
      allow(tcp_socket).to receive(:close)

      allow(stream).to receive(:receive).with(anything())
      allow(stream).to receive(:flush_write_buffer)

      allow(subject).to receive(:stopped?).and_return(false, true)
    end

    describe "#attach" do
      it "register socket to stream" do
        expect(nio).to receive(:register).with(tcp_socket, :r).and_return(monitor)
        subject.attach(tcp_socket, stream)
      end
    end

    describe "#detach" do
      it "deregister socket from stream" do
        expect(nio).to receive(:deregister).with(tcp_socket)
        subject.detach(tcp_socket, stream)
      end
    end
  end

  describe "#stop" do
    it "wakeup stream" do
      allow(Thread).to receive(:new) {}
      expect(subject).to receive(:wakeup)
      subject.attach(tcp_socket, stream)
      subject.stop
    end
  end

end
