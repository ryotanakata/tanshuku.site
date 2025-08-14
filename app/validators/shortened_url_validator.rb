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

  def validate_short_code!(short_code)
    errors = []

    if short_code.blank?
      errors << '短縮コードが生成されていません'
    elsif short_code.length != 6
      errors << '短縮コードは6文字である必要があります'
    elsif !short_code.match?(/^[A-Z0-9]{6}$/)
      errors << '短縮コードは英数字（大文字）である必要があります'
    end

    unless errors.empty?
      raise ValidationError.new(errors)
    end
  end
end
