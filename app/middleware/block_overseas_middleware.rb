class BlockOverseasMiddleware
  def initialize(app)
    @app = app
    @crawler_service = CrawlerService.new
    @ip_address_service = IpAddressService.new
  end

  def call(env)
    request = Rack::Request.new(env)
    ip_address = get_real_ip(request)
    user_agent = request.user_agent

    # デバッグ用ログ（本番環境でも一時的に有効）
    Rails.logger.info "Middleware Debug - Raw IP: #{request.ip}, Real IP: #{ip_address}, X-Forwarded-For: #{request.env['HTTP_X_FORWARDED_FOR']}, X-Real-IP: #{request.env['HTTP_X_REAL_IP']}"

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
          'Content-Type' => 'application/json; charset=utf-8',
          'Cache-Control' => 'no-cache'
        },
        [
          {
            error: 'このサービスは日本国内からのみご利用いただけます',
            message: 'We\'re sorry, this service is only available in Japan.',
            code: 'JAPAN_ONLY'
          }.to_json
        ]
      ]
    end

    @app.call(env)
  end

  private

  def get_real_ip(request)
    # Railway環境でのプロキシヘッダーを確認
    # 優先順位: X-Forwarded-For > X-Real-IP > request.ip
    forwarded_for = request.env['HTTP_X_FORWARDED_FOR']
    real_ip = request.env['HTTP_X_REAL_IP']

    if forwarded_for.present?
      # X-Forwarded-For: client, proxy1, proxy2 の形式
      # 最初のIP（クライアントの実際のIP）を取得
      forwarded_for.split(',').first.strip
    elsif real_ip.present?
      real_ip
    else
      request.ip
    end
  end
end
