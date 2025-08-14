class ShortenedUrlService
  def initialize(shortened_url_repository: ShortenedUrlRepository.new)
    @shortened_url_repository = shortened_url_repository
  end

  def create_shortened_url(url)
    url = url.chomp('/') if url.end_with?('/')
    existing_url = @shortened_url_repository.find_by_original_url(url)
    return existing_url if existing_url

    shortened_url = @shortened_url_repository.create(
      original_url: url,
      short_code: generate_short_code,
      created_at: Time.current
    )

    unless shortened_url.persisted?
      raise ShortenedUrlCreationError.new(shortened_url.errors.full_messages)
    end

    shortened_url
  end

  def find_by_short_code(code)
    @shortened_url_repository.find_by_short_code(code)
  end

  def build_url(code)
    shortened_url = find_by_short_code(code)
    return nil unless shortened_url

    "#{Rails.application.config.base_url}/s/#{shortened_url.short_code}"
  end

  private

  def generate_short_code
    loop do
      short_code = SecureRandom.alphanumeric(6).upcase
      break short_code unless @shortened_url_repository.exists?(short_code)
    end
  end
end
