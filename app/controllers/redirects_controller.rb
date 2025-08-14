class RedirectsController < ApplicationController
  def initialize(shortened_url_service: ShortenedUrlService.new)
    @shortened_url_service = shortened_url_service
  end

  def show
    short_code = params[:short_code]
    shortened_url = @shortened_url_service.expand_url(short_code)

    if shortened_url
      redirect_to shortened_url.original_url, allow_other_host: true
    else
      render file: "#{Rails.root}/public/404.html", status: :not_found, layout: false
    end
  end
end
