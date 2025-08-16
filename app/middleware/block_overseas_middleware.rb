class BlockOverseasMiddleware
  def initialize(app)
    @app = app
    @crawler_service = CrawlerService.new
    @ip_address_service = IpAddressService.new
  end

  def call(env)
    request = Rack::Request.new(env)
    ip_address = request.ip
    user_agent = request.user_agent

    # 開発環境では常に許可
    return @app.call(env) if Rails.env.development?

    # 検索エンジンのクローラーは許可
    if @crawler_service.should_allow_crawler?(user_agent)
      @crawler_service.log_crawler_access(user_agent, ip_address)
      return @app.call(env)
    end

    # 海外IPは拒否
    if @ip_address_service.overseas_ip?(ip_address)
      return [
        403,
        {
          "Content-Type" => "application/json; charset=utf-8",
          "Cache-Control" => "no-cache"
        },
        [
          {
            error: "このサービスは日本国内からのみご利用いただけます",
            message: "We're sorry, this service is only available in Japan.",
            code: "JAPAN_ONLY"
          }.to_json
        ]
      ]
    end

    @app.call(env)
  end
end
