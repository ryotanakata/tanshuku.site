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

      @shortened_url_validator.validate_creation!(original_url)
      shortened_url = @shortened_url_service.create_shortened_url(original_url)

      render json: {
        original_url: shortened_url.original_url,
        short_code: shortened_url.short_code,
        short_url: @shortened_url_service.build_url(shortened_url.short_code),
        created_at: shortened_url.created_at
      }, status: :created
    end

    private

    def url_params
      params.permit(:url)
    end
  end
end
