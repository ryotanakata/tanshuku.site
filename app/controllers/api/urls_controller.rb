module Api
  class UrlsController < BaseController
    def initialize(
      shortened_url_service: ShortenedUrlService.new,
      shortened_url_validator: ShortenedUrlValidator.new
    )
      @shortened_url_service = shortened_url_service
      @shortened_url_validator = shortened_url_validator
    end

    def create
      original_url = url_params[:url]

      validation_result = @shortened_url_validator.validate_creation(original_url)

      unless validation_result[:valid]
        return render json: { errors: validation_result[:errors] }, status: :unprocessable_content
      end

      begin
        shortened_url = @shortened_url_service.create_shortened_url(original_url)

        render json: {
          original_url: shortened_url.original_url,
          short_code: shortened_url.short_code,
          short_url: @shortened_url_service.build_url(shortened_url.short_code),
          created_at: shortened_url.created_at
        }, status: :created
      rescue => e
        Rails.logger.error "API Error: #{e.message}"
        return render json: { error: e.message }, status: :unprocessable_content
      end
    end

    def show
      short_code = params[:id]
      shortened_url = @shortened_url_service.find_by_short_code(short_code)

      if shortened_url
        render json: {
          original_url: shortened_url.original_url,
          short_code: shortened_url.short_code,
          short_url: @shortened_url_service.build_url(shortened_url.short_code),
          created_at: shortened_url.created_at
        }
      else
        render json: { error: '短縮URLが見つかりません' }, status: :not_found
      end
    end

    private

    def url_params
      params.permit(:url)
    end
  end
end
