require 'rails_helper'

RSpec.describe CrawlerService, type: :service do
  let(:service) { described_class.new }

  describe '#search_engine_crawler?' do
    context 'with valid user agent' do
      it 'identifies Google bot' do
        ua = 'Mozilla/5.0 (compatible; Googlebot/2.1; +http://www.google.com/bot.html)'
        expect(service.search_engine_crawler?(ua)).to be true
      end

      it 'identifies Bing bot' do
        ua = 'Mozilla/5.0 (compatible; bingbot/2.0; +http://www.bing.com/bingbot.htm)'
        expect(service.search_engine_crawler?(ua)).to be true
      end

      it 'identifies Yandex bot' do
        ua = 'Mozilla/5.0 (compatible; YandexBot/3.0; +http://yandex.com/bots)'
        expect(service.search_engine_crawler?(ua)).to be true
      end
    end

    context 'with invalid user agent' do
      it 'returns false for nil user agent' do
        expect(service.search_engine_crawler?(nil)).to be false
      end

      it 'returns false for blank user agent' do
        expect(service.search_engine_crawler?('')).to be false
      end

      it 'returns false for regular browser user agent' do
        ua = 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36'
        expect(service.search_engine_crawler?(ua)).to be false
      end
    end
  end

  describe '#social_media_crawler?' do
    context 'with valid user agent' do
      it 'identifies Facebook bot' do
        ua = 'facebookexternalhit/1.1 (+http://www.facebook.com/externalhit_uatext.php)'
        expect(service.social_media_crawler?(ua)).to be true
      end

      it 'identifies Twitter bot' do
        ua = 'Twitterbot/1.0'
        expect(service.social_media_crawler?(ua)).to be true
      end

      it 'identifies LinkedIn bot' do
        ua = 'LinkedInBot/1.0 (compatible; Mozilla/5.0; Apache-HttpClient +http://www.linkedin.com)'
        expect(service.social_media_crawler?(ua)).to be true
      end
    end

    context 'with invalid user agent' do
      it 'returns false for nil user agent' do
        expect(service.social_media_crawler?(nil)).to be false
      end

      it 'returns false for blank user agent' do
        expect(service.social_media_crawler?('')).to be false
      end

      it 'returns false for regular browser user agent' do
        ua = 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36'
        expect(service.social_media_crawler?(ua)).to be false
      end
    end
  end

  describe '#identify_crawler' do
    context 'with valid user agent' do
      it 'identifies Google as google' do
        ua = 'Mozilla/5.0 (compatible; Googlebot/2.1; +http://www.google.com/bot.html)'
        expect(service.identify_crawler(ua)).to eq('google')
      end

      it 'identifies Facebook as facebook' do
        ua = 'facebookexternalhit/1.1 (+http://www.facebook.com/externalhit_uatext.php)'
        expect(service.identify_crawler(ua)).to eq('facebook')
      end

      it 'identifies Bing as bing' do
        ua = 'Mozilla/5.0 (compatible; bingbot/2.0; +http://www.bing.com/bingbot.htm)'
        expect(service.identify_crawler(ua)).to eq('bing')
      end
    end

    context 'with invalid user agent' do
      it 'returns nil for nil user agent' do
        expect(service.identify_crawler(nil)).to be_nil
      end

      it 'returns nil for blank user agent' do
        expect(service.identify_crawler('')).to be_nil
      end

      it 'returns nil for regular browser user agent' do
        ua = 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36'
        expect(service.identify_crawler(ua)).to be_nil
      end
    end
  end

  describe '#should_allow_crawler?' do
    context 'with valid user agent' do
      it 'allows Google bot' do
        ua = 'Mozilla/5.0 (compatible; Googlebot/2.1; +http://www.google.com/bot.html)'
        expect(service.should_allow_crawler?(ua)).to be true
      end

      it 'allows Bing bot' do
        ua = 'Mozilla/5.0 (compatible; bingbot/2.0; +http://www.bing.com/bingbot.htm)'
        expect(service.should_allow_crawler?(ua)).to be true
      end

      it 'allows Facebook bot' do
        ua = 'facebookexternalhit/1.1 (+http://www.facebook.com/externalhit_uatext.php)'
        expect(service.should_allow_crawler?(ua)).to be true
      end
    end

    context 'with invalid user agent' do
      it 'allows nil user agent' do
        expect(service.should_allow_crawler?(nil)).to be true
      end

      it 'allows blank user agent' do
        expect(service.should_allow_crawler?('')).to be true
      end

      it 'allows regular browser user agent' do
        ua = 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36'
        expect(service.should_allow_crawler?(ua)).to be false
      end
    end
  end

  describe '#log_crawler_access' do
    let(:ua) { 'Mozilla/5.0 (compatible; Googlebot/2.1; +http://www.google.com/bot.html)' }
    let(:ip) { '66.249.66.1' }

    it 'logs crawler access when crawler is identified' do
      allow(Rails.logger).to receive(:info)
      service.log_crawler_access(ua, ip)
      expect(Rails.logger).to have_received(:info).with("Crawler access: google (#{ua}) from #{ip}")
    end

    it 'does not log when no crawler is identified' do
      allow(Rails.logger).to receive(:info)
      service.log_crawler_access('Mozilla/5.0 (Windows NT 10.0; Win64; x64)', ip)
      expect(Rails.logger).not_to have_received(:info)
    end

    it 'handles nil user agent gracefully' do
      expect { service.log_crawler_access(nil, ip) }.not_to raise_error
    end
  end
end
