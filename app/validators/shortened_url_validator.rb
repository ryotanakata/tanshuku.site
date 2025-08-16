class ShortenedUrlValidator
  REGEX_HOST = /^(?!\d+\.\d+\.\d+\.\d+$)[a-zA-Z0-9]([a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(\.[a-zA-Z0-9]([a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)+$/

  def validate_creation!(url)
    errors = []

    if url.blank?
      errors << "URLを入力してください"
    else
      begin
        uri = URI.parse(url)

        # プロトコル検証
        unless uri.scheme&.match?(/^https?$/)
          errors << "http://またはhttps://から始まるURLを入力してください"
        end

        # ホスト名検証
        unless uri.host&.match?(REGEX_HOST)
          errors << "有効なドメインを含むURLを入力してください"
        end

        # ブロックされたドメインのチェック
        if SiteConfig::BLOCKED_DOMAINS.any? { |domain| uri.host&.downcase&.end_with?(domain) }
          errors << "このURLは短縮できません"
        end
      rescue URI::InvalidURIError
        errors << "無効なURL形式です"
      end
    end

    if url.present?
      if url.length > 2048
        errors << "URLが長すぎます（2048文字以内で入力してください）"
      end
    end

    unless errors.empty?
      raise ValidationError.new(errors)
    end
  end
end
