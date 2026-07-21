require 'rails_helper'

RSpec.describe LogRedirectJob, type: :job do
  let(:redirect_log_service)      { instance_double(RedirectLogService) }
  let(:shortened_url_repository)  { instance_double(ShortenedUrlRepository) }
  let(:job) do
    described_class.new(
      redirect_log_service: redirect_log_service,
      shortened_url_repository: shortened_url_repository
    )
  end
  let(:shortened_url) { ShortenedUrl.new(id: 1, original_url: 'https://example.com', short_code: 'ABC123') }

  describe '#perform' do
    let(:args) do
      {
        shortened_url_id: 1,
        ip_address: '203.0.113.1',
        user_agent: 'Mozilla/5.0',
        referer: 'https://google.com'
      }
    end

    context 'when the URL exists' do
      before do
        allow(shortened_url_repository).to receive(:find_by_id).with(1).and_return(shortened_url)
        allow(redirect_log_service).to receive(:create_redirect_log)
      end

      it 'delegates to RedirectLogService' do
        job.perform(**args)
        expect(redirect_log_service).to have_received(:create_redirect_log).with(
          shortened_url,
          ip_address: '203.0.113.1',
          user_agent: 'Mozilla/5.0',
          referer: 'https://google.com'
        )
      end
    end

    context 'when the URL does not exist' do
      before do
        allow(shortened_url_repository).to receive(:find_by_id).with(1).and_return(nil)
      end

      it 'does nothing without raising' do
        expect { job.perform(**args) }.not_to raise_error
        expect(redirect_log_service).not_to receive(:create_redirect_log)
      end
    end
  end
end
