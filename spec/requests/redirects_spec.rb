require 'rails_helper'

RSpec.describe 'Redirects', type: :request do
  let!(:shortened_url) do
    ShortenedUrl.create!(original_url: 'https://example.com', short_code: 'ABC123')
  end

  let(:mock_country_db) { instance_double(MaxMind::DB) }
  let(:mock_city_db)    { instance_double(MaxMind::DB) }
  let(:mock_isp_db)     { instance_double(MaxMind::DB) }

  before do
    allow(IpAddressService).to receive(:country_db).and_return(mock_country_db)
    allow(IpAddressService).to receive(:city_db).and_return(mock_city_db)
    allow(IpAddressService).to receive(:isp_db).and_return(mock_isp_db)
    allow(LogRedirectJob).to receive(:perform_later)
    allow(Rails.logger).to receive(:info)
    allow(Rails.logger).to receive(:error)
  end

  describe 'GET /:short_code' do
    context 'when domestic IP (JP)' do
      before do
        allow(mock_country_db).to receive(:get).and_return({ 'country' => { 'iso_code' => 'JP' } })
      end

      it 'redirects to the original URL' do
        get '/ABC123', env: { 'REMOTE_ADDR' => '203.0.113.1' }
        expect(response).to redirect_to('https://example.com')
      end

      it 'enqueues LogRedirectJob' do
        get '/ABC123', env: { 'REMOTE_ADDR' => '203.0.113.1' }
        expect(LogRedirectJob).to have_received(:perform_later).with(
          hash_including(shortened_url_id: shortened_url.id)
        )
      end
    end

    context 'when overseas IP' do
      before do
        allow(mock_country_db).to receive(:get).and_return({ 'country' => { 'iso_code' => 'US' } })
      end

      it 'returns 403 for a regular user agent' do
        get '/ABC123', env: { 'REMOTE_ADDR' => '8.8.8.8' }
        expect(response).to have_http_status(:forbidden)
      end

      it 'does not enqueue LogRedirectJob on 403' do
        get '/ABC123', env: { 'REMOTE_ADDR' => '8.8.8.8' }
        expect(LogRedirectJob).not_to have_received(:perform_later)
      end

      it 'allows search engine crawlers through' do
        get '/ABC123',
          env: { 'REMOTE_ADDR' => '66.249.66.1' },
          headers: { 'User-Agent' => 'Mozilla/5.0 (compatible; Googlebot/2.1)' }
        expect(response).to redirect_to('https://example.com')
      end

      it 'allows SNS preview bots through and renders OGP page' do
        get '/ABC123',
          env: { 'REMOTE_ADDR' => '8.8.8.8' },
          headers: { 'User-Agent' => 'facebookexternalhit/1.1' }
        expect(response).to have_http_status(:ok)
      end

      it 'does not misidentify LINE app as SNS bot' do
        get '/ABC123',
          env: { 'REMOTE_ADDR' => '8.8.8.8' },
          headers: { 'User-Agent' => 'Mozilla/5.0 (iPhone; CPU iPhone OS 17_0) Line/13.20.0' }
        expect(response).to have_http_status(:forbidden)
      end
    end

    context 'when short_code does not exist' do
      it 'returns 404' do
        get '/XXXXXX'
        expect(response).to have_http_status(:not_found)
      end
    end
  end
end
