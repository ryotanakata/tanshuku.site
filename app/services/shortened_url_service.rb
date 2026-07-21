class ShortenedUrlService
  def initialize(shortened_url_repository: ShortenedUrlRepository.new)
    @shortened_url_repository = shortened_url_repository
  end

  def create_shortened_url(url)
    url = normalize_url(url)
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
  rescue ActiveRecord::RecordNotUnique
    @shortened_url_repository.find_by_original_url(url)
  end

  def find_by_short_code(code)
    @shortened_url_repository.find_by_short_code(code)
  end

  def build_url(host, code)
    shortened_url = find_by_short_code(code)
    return nil unless shortened_url

    "#{host}/#{shortened_url.short_code}"
  end

  private

  def normalize_url(url)
    uri = URI.parse(url)
    uri.host = uri.host&.downcase
    uri.to_s.chomp("/")
  rescue URI::InvalidURIError
    url.chomp("/")
  end

  def generate_short_code
    loop do
      short_code = SecureRandom.alphanumeric(6).upcase
      break short_code unless @shortened_url_repository.exists?(short_code)
    end
  end
end
