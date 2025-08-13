class ShortenedUrlValidator
  def self.validate_creation(original_url)
    # URLの基本バリデーション
    url_validation = UrlValidator.validate(original_url)
    return url_validation unless url_validation[:valid]

    # 短縮URL作成に特化したバリデーション
    errors = []

    # URLの長さチェック（極端に長いURLを防ぐ）
    if original_url.length > 2048
      errors << 'URLが長すぎます（2048文字以内で入力してください）'
    end

    if errors.empty?
      { valid: true, errors: [] }
    else
      { valid: false, errors: errors }
    end
  end

  def self.validate_short_code(short_code)
    errors = []

    if short_code.blank?
      errors << '短縮コードが生成されていません'
    elsif short_code.length != 6
      errors << '短縮コードは6文字である必要があります'
    elsif !short_code.match?(/^[A-Z0-9]{6}$/)
      errors << '短縮コードは英数字（大文字）である必要があります'
    end

    if errors.empty?
      { valid: true, errors: [] }
    else
      { valid: false, errors: errors }
    end
  end
end
