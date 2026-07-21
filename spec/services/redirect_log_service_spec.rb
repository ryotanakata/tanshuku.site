require 'rails_helper'

RSpec.describe RedirectLogService, type: :service do
  let(:repository)        { instance_double(RedirectLogRepository) }
  let(:ip_address_service) { instance_double(IpAddressService) }
  let(:service) do
    described_class.new(
      redirect_log_repository: repository,
      ip_address_service: ip_address_service
    )
  end
  let(:shortened_url) do
    ShortenedUrl.new(original_url: 'https://example.com', short_code: 'ABC123')
  end
  let(:geo) { { country: 'JP', city: 'Tokyo', isp: 'NTT Communications' } }

  describe '#create_redirect_log' do
    context 'when domestic IP' do
      before do
        allow(ip_address_service).to receive(:overseas_ip?).with('203.0.113.1').and_return(false)
        allow(ip_address_service).to receive(:lookup_geo_db).with('203.0.113.1').and_return(geo)
        allow(repository).to receive(:create_log).and_return(true)
      end

      it 'creates a full log with geo info' do
        service.create_redirect_log(
          shortened_url,
          ip_address: '203.0.113.1',
          user_agent: 'Mozilla/5.0',
          referer: 'https://google.com'
        )
        expect(repository).to have_received(:create_log).with(
          hash_including(
            shortened_url: shortened_url,
            ip_address: '203.0.113.1',
            user_agent: 'Mozilla/5.0',
            referer: 'https://google.com',
            country: 'JP',
            city: 'Tokyo',
            isp: 'NTT Communications'
          )
        )
      end
    end

    context 'when overseas IP' do
      before do
        allow(ip_address_service).to receive(:overseas_ip?).with('8.8.8.8').and_return(true)
        allow(repository).to receive(:create_log).and_return(true)
      end

      it 'creates an anonymous log' do
        service.create_redirect_log(
          shortened_url,
          ip_address: '8.8.8.8',
          user_agent: 'Mozilla/5.0',
          referer: 'https://google.com'
        )
        expect(repository).to have_received(:create_log).with(
          hash_including(
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

  describe '#create_log' do
    it 'creates a redirect log with full information' do
      allow(repository).to receive(:create_log).and_return(true)

      service.create_log(
        shortened_url,
        ip_address: '203.0.113.1',
        user_agent: 'Mozilla/5.0',
        referer: 'https://google.com',
        geo: geo
      )

      expect(repository).to have_received(:create_log).with(
        hash_including(
          shortened_url: shortened_url,
          ip_address: '203.0.113.1',
          user_agent: 'Mozilla/5.0',
          referer: 'https://google.com',
          country: 'JP',
          city: 'Tokyo',
          isp: 'NTT Communications'
        )
      )
    end

    it 'falls back to "unknown" when ip_address is nil' do
      allow(repository).to receive(:create_log).and_return(true)

      service.create_log(shortened_url, ip_address: nil, user_agent: nil, referer: nil, geo: geo)

      expect(repository).to have_received(:create_log).with(
        hash_including(ip_address: 'unknown', user_agent: 'unknown', referer: 'unknown')
      )
    end
  end

  describe '#create_anonymous_log' do
    it 'creates an anonymous redirect log with all fields set to unknown' do
      allow(repository).to receive(:create_log).and_return(true)

      service.create_anonymous_log(shortened_url)

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
