class ShortenedUrlValidator
  def validate_creation!(url)
    errors = []

    if url.blank?
      errors << 'URLを入力してください'
    else
      begin
        uri = URI.parse(url)
        unless uri.is_a?(URI::HTTP) || uri.is_a?(URI::HTTPS)
          errors << 'HTTPまたはHTTPSのURLを入力してください'
        end

        if uri.hostname.blank?
          errors << '有効なドメインを含むURLを入力してください'
        end

        if SiteConfig::BLOCKED_DOMAINS.any? { |domain| uri.hostname&.downcase&.end_with?(domain) }
          errors << 'このURLは短縮できません'
        end
      rescue URI::InvalidURIError
        errors << '無効なURL形式です'
      end
    end

    if url.present?
      if url.length > 2048
        errors << 'URLが長すぎます（2048文字以内で入力してください）'
      end
    end

    unless errors.empty?
      raise ValidationError.new(errors)
    end
  end
end
