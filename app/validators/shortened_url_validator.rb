class ShortenedUrlValidator
  def validate_creation(original_url)
    errors = []

    # 基本的なURLバリデーション
    if original_url.blank?
      errors << 'URLを入力してください'
    else
      # URL形式のチェック
      begin
        uri = URI.parse(original_url)
        unless uri.is_a?(URI::HTTP) || uri.is_a?(URI::HTTPS)
          errors << 'HTTPまたはHTTPSのURLを入力してください'
        end

        # ホスト名のチェック
        if uri.hostname.blank?
          errors << '有効なドメインを含むURLを入力してください'
        end
      rescue URI::InvalidURIError
        errors << '無効なURL形式です'
      end
    end

    # 短縮URL作成に特化したバリデーション
    if original_url.present?
      # URLの長さチェック（極端に長いURLを防ぐ）
      if original_url.length > 2048
        errors << 'URLが長すぎます（2048文字以内で入力してください）'
      end
    end

    if errors.empty?
      { valid: true, errors: [] }
    else
      { valid: false, errors: errors }
    end
  end

  def validate_short_code(short_code)
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
