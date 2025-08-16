require 'rails_helper'

RSpec.describe RedirectLogRepository, type: :repository do
  let(:repository) { described_class.new }
  let(:shortened_url) do
    ShortenedUrl.create!(
      original_url: 'https://example.com',
      short_code: 'ABC123'
    )
  end
  let(:log_data) do
    {
      shortened_url: shortened_url,
      ip_address: '203.0.113.1',
      country: 'JP',
      city: 'Tokyo',
      isp: 'NTT Communications',
      user_agent: 'Mozilla/5.0 (Windows NT 10.0; Win64; x64)',
      referer: 'https://google.com'
    }
  end

  describe '#create_log' do
    it 'creates a new redirect log' do
      expect {
        repository.create_log(log_data)
      }.to change(RedirectLog, :count).by(1)
    end

    it 'creates log with correct attributes' do
      result = repository.create_log(log_data)
      expect(result.shortened_url).to eq(shortened_url)
      expect(result.ip_address).to eq('203.0.113.1')
      expect(result.country).to eq('JP')
      expect(result.city).to eq('Tokyo')
      expect(result.isp).to eq('NTT Communications')
      expect(result.user_agent).to eq('Mozilla/5.0 (Windows NT 10.0; Win64; x64)')
      expect(result.referer).to eq('https://google.com')
    end

    it 'returns the created redirect log' do
      result = repository.create_log(log_data)
      expect(result).to be_a(RedirectLog)
      expect(result).to be_persisted
    end
  end
end
