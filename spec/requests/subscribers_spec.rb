require 'spec_helper'

describe 'Subscribers' do

  context 'with valid subscription' do
    it 'redirects to referer' do
      post '/subscribers',
        { chimpy_subscriber: { email: 'foo2@bar.com', subscribed: true } },
        { referer: 'http://foo.bar' }

      expect(response).to be_redirect
      expect(response.location).to eq('http://foo.bar')
    end

    it 'redirects to root URL if no referer' do
      post '/subscribers',
        { chimpy_subscriber: { email: 'foo2@bar.com', subscribed: true } },
        { referer: nil }

      expect(response).to be_redirect
      expect(response.location).to eq('http://www.example.com/')
    end
  end

  context 'with json response' do
    it 'returns 200 with json data' do
      post '/subscribers', format: :json, chimpy_subscriber: { email: 'foo2@bar.com', subscribed: true }

      expect(response).to be_success
      json_response = JSON.parse(response.body)
      expect(json_response['email']).to eq('foo2@bar.com')
    end
  end
end