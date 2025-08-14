class BlockOverseasMiddleware
  def initialize(app)
    @app = app
    @crawler_service = CrawlerService.new
    @ip_address_service = IpAddressService.new
  end

  def call(env)
    request = Rack::Request.new(env)
    ip = @ip_address_service.extract_client_ip(request)

    return @app.call(env) if Rails.env.development?
    return @app.call(env) if crawler?(request, ip)
    return response_overseas if @ip_address_service.overseas_ip?(ip)

    @app.call(env)
  end

  private

  def crawler?(request, ip)
    @crawler_service.should_allow_crawler?(request.user_agent).tap do |allowed|
      @crawler_service.log_crawler_access(request.user_agent, ip) if allowed
    end
  end

  def response_overseas
    status = 403
    headers = {
      'Content-Type' => 'application/json; charset=utf-8',
      'Cache-Control' => 'no-cache'
    }
    body = [
      {
        error: 'このサービスは日本国内からのみご利用いただけます',
        message: 'We\'re sorry, this service is only available in Japan.',
        code: 'JAPAN_ONLY'
      }.to_json
    ]

    [ status, headers, body ]
  end
end
