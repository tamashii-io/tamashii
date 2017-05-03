# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Tamashii::Server::Response do
  it 'add version to response body' do
    body = JSON.parse(subject.body.first)
    expect(body).to be_has_key('version')
  end

  it 'response as json' do
    expect(subject.headers).to be_has_value('application/json')
  end
end
