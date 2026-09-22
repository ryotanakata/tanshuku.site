require 'rails_helper'

RSpec.describe LogRedirectJob, type: :job do
  describe '#perform' do
    let(:redirect_log_service)     { instance_double(RedirectLogService) }
    let(:shortened_url_repository) { instance_double(ShortenedUrlRepository) }
    let(:shortened_url) { ShortenedUrl.new(id: 1, original_url: 'https://example.com', short_code: 'ABC123') }

    let(:args) do
      {
        shortened_url_id: 1,
        ip_address: '203.0.113.1',
        user_agent: 'Mozilla/5.0',
        referer: 'https://google.com'
      }
    end

    before do
      allow(RedirectLogService).to receive(:new).and_return(redirect_log_service)
      allow(ShortenedUrlRepository).to receive(:new).and_return(shortened_url_repository)
    end

    context 'when the URL exists' do
      before do
        allow(shortened_url_repository).to receive(:find_by_id).with(1).and_return(shortened_url)
        allow(redirect_log_service).to receive(:create_redirect_log)
      end

      it 'delegates to RedirectLogService' do
        described_class.new.perform(**args)
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
        expect(redirect_log_service).not_to receive(:create_redirect_log)
        expect { described_class.new.perform(**args) }.not_to raise_error
      end
    end
  end

  describe 'enqueueing through the :async adapter' do
    let!(:shortened_url) do
      ShortenedUrl.create!(original_url: 'https://example.com/async', short_code: 'ASYNC1')
    end

    # immediate= は :async アダプタを呼び出しスレッド上で実行させる。別スレッドだと
    # トランザクション内のテストデータが見えず、INSERT もロールバック対象外になる。
    around do |example|
      original_adapter = described_class.queue_adapter
      adapter = ActiveJob::QueueAdapters::AsyncAdapter.new
      adapter.immediate = true
      described_class.queue_adapter = adapter
      example.run
      described_class.queue_adapter = original_adapter
    end

    it 'creates one RedirectLog without any queue backend table' do
      expect {
        described_class.perform_later(
          shortened_url_id: shortened_url.id,
          ip_address: '133.242.0.1',
          user_agent: 'Mozilla/5.0',
          referer: 'https://google.com'
        )
      }.to change(RedirectLog, :count).by(1)
    end
  end
end
