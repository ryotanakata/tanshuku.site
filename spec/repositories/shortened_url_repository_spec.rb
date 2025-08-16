require 'rails_helper'

RSpec.describe ShortenedUrlRepository, type: :repository do
  let(:repository) { described_class.new }

  describe '#create' do
    let(:attributes) do
      {
        original_url: 'https://example.com',
        short_code: 'ABC123'
      }
    end

    it 'creates a new shortened URL' do
      expect {
        repository.create(attributes)
      }.to change(ShortenedUrl, :count).by(1)
    end

    it 'returns the created shortened URL' do
      result = repository.create(attributes)
      expect(result).to be_a(ShortenedUrl)
      expect(result.original_url).to eq('https://example.com')
      expect(result.short_code).to eq('ABC123')
    end
  end

  describe '#find_by_short_code' do
    let!(:shortened_url) do
      ShortenedUrl.create!(
        original_url: 'https://example.com',
        short_code: 'ABC123'
      )
    end

    it 'finds shortened URL by short code' do
      result = repository.find_by_short_code('ABC123')
      expect(result).to eq(shortened_url)
    end

    it 'finds shortened URL by lowercase short code' do
      result = repository.find_by_short_code('abc123')
      expect(result).to eq(shortened_url)
    end

    it 'returns nil for non-existent short code' do
      result = repository.find_by_short_code('XYZ789')
      expect(result).to be_nil
    end
  end

  describe '#find_by_original_url' do
    let!(:shortened_url) do
      ShortenedUrl.create!(
        original_url: 'https://example.com',
        short_code: 'ABC123'
      )
    end

    it 'finds shortened URL by original URL' do
      result = repository.find_by_original_url('https://example.com')
      expect(result).to eq(shortened_url)
    end
  end

  describe '#exists?' do
    let!(:shortened_url) do
      ShortenedUrl.create!(
        original_url: 'https://example.com',
        short_code: 'ABC123'
      )
    end

    it 'returns true for existing short code' do
      expect(repository.exists?('ABC123')).to be true
    end

    it 'returns true for existing short code in lowercase' do
      expect(repository.exists?('abc123')).to be true
    end

    it 'returns false for non-existent short code' do
      expect(repository.exists?('XYZ789')).to be false
    end
  end

  describe '#delete' do
    let!(:shortened_url) do
      ShortenedUrl.create!(
        original_url: 'https://example.com',
        short_code: 'ABC123'
      )
    end

    it 'deletes the shortened URL' do
      expect {
        repository.delete(shortened_url.id)
      }.to change(ShortenedUrl, :count).by(-1)
    end
  end
end
