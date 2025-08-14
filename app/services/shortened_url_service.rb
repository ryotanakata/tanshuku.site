class ShortenedUrlService
  def initialize(shortened_url_repository: ShortenedUrlRepository.new)
    @shortened_url_repository = shortened_url_repository
  end

  def create_shortened_url(original_url)
    # 既存の短縮URLがあるかチェック
    existing_url = @shortened_url_repository.find_by_original_url(original_url)
    return existing_url if existing_url

    # 短縮コードを生成
    short_code = generate_unique_short_code

    # 新しい短縮URLを作成
    shortened_url = @shortened_url_repository.create(
      original_url: original_url,
      short_code: short_code,
      created_at: Time.current
    )

    # 失敗時は例外を投げる
    unless shortened_url.persisted?
      raise "Failed to create shortened URL: #{shortened_url.errors.full_messages.join(', ')}"
    end

    shortened_url
  end

  def find_by_short_code(short_code)
    @shortened_url_repository.find_by_short_code(short_code)
  end

  def build_url(short_code)
    shortened_url = find_by_short_code(short_code)
    return nil unless shortened_url

    "#{Rails.application.config.base_url}/s/#{shortened_url.short_code}"
  end

  private

  def generate_unique_short_code
    loop do
      short_code = SecureRandom.alphanumeric(6).upcase
      break short_code unless @shortened_url_repository.exists?(short_code)
    end
  end
end
