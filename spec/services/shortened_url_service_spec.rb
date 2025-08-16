require 'rails_helper'

RSpec.describe ShortenedUrlService, type: :service do
  let(:repository) { instance_double(ShortenedUrlRepository) }
  let(:service) { described_class.new(shortened_url_repository: repository) }
  let(:url) { 'https://example.com/page' }
  let(:short_code) { 'ABC123' }
  let(:shortened_url) do
    ShortenedUrl.new(
      original_url: url,
      short_code: short_code
    )
  end

  describe '#create_shortened_url' do
    before do
      allow(repository).to receive(:find_by_original_url).with(url).and_return(nil)
      allow(repository).to receive(:create).and_return(shortened_url)
      allow(shortened_url).to receive(:persisted?).and_return(true)
    end

    it 'creates a new shortened URL' do
      allow(SecureRandom).to receive(:alphanumeric).with(6).and_return('abc123')
      allow(repository).to receive(:exists?).with('ABC123').and_return(false)

      service.create_shortened_url(url)
      expect(repository).to have_received(:create).with(
        hash_including(original_url: url)
      )
    end

    it 'returns the created shortened URL' do
      allow(SecureRandom).to receive(:alphanumeric).with(6).and_return('abc123')
      allow(repository).to receive(:exists?).with('ABC123').and_return(false)

      result = service.create_shortened_url(url)
      expect(result).to eq(shortened_url)
    end

    context 'when URL already exists' do
      let(:existing_shortened_url) do
        ShortenedUrl.new(
          original_url: url,
          short_code: 'EXISTING'
        )
      end

      before do
        allow(repository).to receive(:find_by_original_url).with(url).and_return(existing_shortened_url)
      end

      it 'returns the existing shortened URL' do
        result = service.create_shortened_url(url)
        expect(result).to eq(existing_shortened_url)
      end

      it 'does not create a new shortened URL' do
        service.create_shortened_url(url)
        expect(repository).not_to have_received(:create)
      end
    end

    context 'when creation fails' do
      let(:invalid_shortened_url) do
        ShortenedUrl.new(
          original_url: url,
          short_code: short_code
        )
      end

      before do
        allow(SecureRandom).to receive(:alphanumeric).with(6).and_return('abc123')
        allow(repository).to receive(:exists?).with('ABC123').and_return(false)
        allow(repository).to receive(:create).and_return(invalid_shortened_url)
        allow(invalid_shortened_url).to receive(:persisted?).and_return(false)
        allow(invalid_shortened_url).to receive(:errors).and_return(
          double(full_messages: [ "Error message" ])
        )
      end

      it 'raises ShortenedUrlCreationError' do
        expect { service.create_shortened_url(url) }.to raise_error(ShortenedUrlCreationError)
      end
    end
  end

  describe '#find_by_short_code' do
    let(:code) { 'ABC123' }

    it 'finds shortened URL by short code' do
      allow(repository).to receive(:find_by_short_code).with(code).and_return(shortened_url)
      result = service.find_by_short_code(code)
      expect(result).to eq(shortened_url)
    end
  end

  describe '#build_url' do
    let(:host) { 'https://short.ly' }
    let(:code) { 'ABC123' }

    context 'when shortened URL exists' do
      before do
        allow(repository).to receive(:find_by_short_code).with(code).and_return(shortened_url)
      end

      it 'returns built URL' do
        result = service.build_url(host, code)
        expect(result).to eq("#{host}/#{code}")
      end
    end

    context 'when shortened URL does not exist' do
      before do
        allow(repository).to receive(:find_by_short_code).with(code).and_return(nil)
      end

      it 'returns nil' do
        result = service.build_url(host, code)
        expect(result).to be_nil
      end
    end
  end

  describe '#generate_short_code' do
    let(:url) { 'https://example.com/page' }
    let(:shortened_url) do
      ShortenedUrl.new(
        original_url: url,
        short_code: 'ABC123'
      )
    end

    before do
      allow(repository).to receive(:find_by_original_url).with(url).and_return(nil)
      allow(repository).to receive(:create).and_return(shortened_url)
      allow(shortened_url).to receive(:persisted?).and_return(true)
    end

    it 'generates a 6-character alphanumeric code' do
      allow(SecureRandom).to receive(:alphanumeric).with(6).and_return('abc123')
      allow(repository).to receive(:exists?).with('ABC123').and_return(false)

      service.create_shortened_url(url)

      expect(repository).to have_received(:create).with(
        hash_including(short_code: 'ABC123')
      )
    end

    it 'retries if generated code already exists' do
      allow(SecureRandom).to receive(:alphanumeric).with(6)
        .and_return('EXISTS', 'UNIQUE')
      allow(repository).to receive(:exists?).with('EXISTS').and_return(true)
      allow(repository).to receive(:exists?).with('UNIQUE').and_return(false)

      service.create_shortened_url(url)

      expect(repository).to have_received(:exists?).with('EXISTS')
      expect(repository).to have_received(:exists?).with('UNIQUE')
    end
  end
end
