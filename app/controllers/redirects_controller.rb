class RedirectsController < ApplicationController
  def show
    short_code = params[:short_code]
    shortened_url = ShortenedUrlService.expand_url(short_code)

    if shortened_url
      redirect_to shortened_url.original_url, allow_other_host: true
    else
      render file: "#{Rails.root}/public/404.html", status: :not_found, layout: false
    end
  end
end
