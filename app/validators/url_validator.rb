class UrlValidator
  def self.valid?(url)
    return false if url.blank?

    uri = URI.parse(url)
    uri.is_a?(URI::HTTP) || uri.is_a?(URI::HTTPS)
  rescue URI::InvalidURIError
    false
  end

  def self.errors_for(url)
    errors = []

    if url.blank?
      errors << 'URLが入力されていません'
    elsif !valid?(url)
      errors << '無効なURL形式です'
    end

    errors
  end

  def self.validate(url)
    errors = errors_for(url)

    if errors.empty?
      { valid: true, errors: [] }
    else
      { valid: false, errors: errors }
    end
  end
end
