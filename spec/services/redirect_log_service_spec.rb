require 'rails_helper'

RSpec.describe RedirectLogService, type: :service do
  let(:repository) { instance_double(RedirectLogRepository) }
  let(:service) { described_class.new(redirect_log_repository: repository) }
  let(:shortened_url) do
    ShortenedUrl.new(
      original_url: 'https://example.com',
      short_code: 'ABC123'
    )
  end
  let(:request) { double('request') }

  before do
    allow(request).to receive(:remote_ip).and_return('203.0.113.1')
    allow(request).to receive(:user_agent).and_return('Mozilla/5.0 (Windows NT 10.0; Win64; x64)')
    allow(request).to receive(:referer).and_return('https://google.com')
  end

  describe '#create_log' do
    let(:geo_info) do
      {
        country: 'JP',
        city: 'Tokyo',
        isp: 'NTT Communications'
      }
    end

    it 'creates a redirect log with full information' do
      allow(repository).to receive(:create_log).and_return(true)
      service.create_log(shortened_url, request, geo_info)
      expect(repository).to have_received(:create_log).with(
        hash_including(
          shortened_url: shortened_url,
          ip_address: '203.0.113.1',
          user_agent: 'Mozilla/5.0 (Windows NT 10.0; Win64; x64)',
          referer: 'https://google.com',
          country: 'JP',
          city: 'Tokyo',
          isp: 'NTT Communications'
        )
      )
    end

    context 'with partial geo information' do
      let(:partial_geo) { { country: 'US', city: nil, isp: 'Comcast' } }

      it 'handles nil geo values gracefully' do
        allow(repository).to receive(:create_log).and_return(true)
        service.create_log(shortened_url, request, partial_geo)
        expect(repository).to have_received(:create_log).with(
          hash_including(
            country: 'US',
            city: nil,
            isp: 'Comcast'
          )
        )
      end
    end
  end

  describe '#create_anonymous_log' do
    it 'creates an anonymous redirect log' do
      allow(repository).to receive(:create_log).and_return(true)
      service.create_anonymous_log(shortened_url, request)
      expect(repository).to have_received(:create_log).with(
        hash_including(
          shortened_url: shortened_url,
          ip_address: 'unknown',
          user_agent: 'unknown',
          referer: 'unknown',
          country: 'unknown',
          city: 'unknown',
          isp: 'unknown'
        )
      )
    end
  end
end
