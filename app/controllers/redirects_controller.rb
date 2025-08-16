class RedirectsController < ApplicationController
  def initialize(
    shortened_url_service: ShortenedUrlService.new,
    redirect_log_service: RedirectLogService.new,
    ip_address_service: IpAddressService.new,
    crawler_service: CrawlerService.new
  )
    @shortened_url_service = shortened_url_service
    @redirect_log_service = redirect_log_service
    @ip_address_service = ip_address_service
    @crawler_service = crawler_service
  end

  def show
    short_code = params[:short_code]
    short_code = short_code.chomp("/") if short_code.end_with?("/")
    shortened_url = @shortened_url_service.find_by_short_code(short_code)

    if shortened_url
      begin
        ip = request.remote_ip

        if @crawler_service.search_engine_crawler?(request.user_agent)
          Rails.logger.info "Crawler access to short_code: #{short_code} by #{@crawler_service.identify_crawler(request.user_agent)}"
        end

        if @ip_address_service.overseas_ip?(ip)
          @redirect_log_service.create_anonymous_log(shortened_url, request)
        else
          geo = @ip_address_service.lookup_geo_db(ip)
          @redirect_log_service.create_log(shortened_url, request, geo)
        end
      rescue => e
        Rails.logger.error "Failed to create redirect log: #{e.message}"
      end

      if @crawler_service.social_media_crawler?(request.user_agent)
        render_ogp_page(shortened_url)
      else
        redirect_to shortened_url.original_url, allow_other_host: true
      end
    else
      render file: "#{Rails.root}/public/404.html", status: :not_found, layout: false
    end
  end

  private

  def render_ogp_page(url)
    @shortened_url = url
    @original_url = url.original_url
    @short_code = url.short_code

    render "pages/ogp", layout: false
  end
end
