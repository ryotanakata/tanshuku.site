module Api
  class UrlsController < BaseController
    def create
      # デバッグ用ログ
      Rails.logger.info "Received params: #{params.inspect}"

      original_url = url_params[:url]

      # バリデーション
      validation_result = ShortenedUrlValidator.validate_creation(original_url)
      unless validation_result[:valid]
        return render json: { errors: validation_result[:errors] }, status: :unprocessable_entity
      end

      # サービスで短縮URLを作成（バリデーション済み）
      result = ShortenedUrlService.shorten_url(original_url)

      if result[:success]
        shortened_url = result[:data]
        render json: {
          original_url: shortened_url.original_url,
          short_code: shortened_url.short_code,
          short_url: ShortenedUrlService.get_full_short_url(shortened_url.short_code),
          created_at: shortened_url.created_at
        }, status: :created
      else
        render json: { errors: result[:errors] }, status: :unprocessable_entity
      end
    end

    def show
      short_code = params[:id]
      shortened_url = ShortenedUrlService.expand_url(short_code)

      if shortened_url
        render json: {
          original_url: shortened_url.original_url,
          short_code: shortened_url.short_code,
          short_url: ShortenedUrlService.get_full_short_url(shortened_url.short_code),
          created_at: shortened_url.created_at
        }
      else
        render json: { error: '短縮URLが見つかりません' }, status: :not_found
      end
    end

    # デバッグ用のテストエンドポイント
    def test
      render json: { message: 'API is working!', timestamp: Time.current }
    end

    private

    def url_params
      params.permit(:url)
    end
  end
end
