class ShortenedUrlService
  def self.shorten_url(original_url)
    # 既存の短縮URLがあるかチェック
    existing_url = ShortenedUrlRepository.find_by_original_url(original_url)
    return { success: true, data: existing_url } if existing_url

    # 短縮コードを生成
    short_code = generate_unique_short_code

    # 新しい短縮URLを作成
    shortened_url = ShortenedUrlRepository.create(
      original_url: original_url,
      short_code: short_code,
      created_at: Time.current
    )

    if shortened_url.persisted?
      { success: true, data: shortened_url }
    else
      { success: false, errors: shortened_url.errors.full_messages }
    end
  end

  def self.expand_url(short_code)
    ShortenedUrlRepository.find_by_short_code(short_code)
  end

  def self.get_full_short_url(short_code)
    shortened_url = expand_url(short_code)
    return nil unless shortened_url

    "#{Rails.application.config.base_url}/s/#{shortened_url.short_code}"
  end

  private

  def self.generate_unique_short_code
    loop do
      short_code = SecureRandom.alphanumeric(6).upcase
      break short_code unless ShortenedUrlRepository.exists?(short_code)
    end
  end
end
