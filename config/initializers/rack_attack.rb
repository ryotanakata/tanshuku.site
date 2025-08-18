class Rack::Attack
  Rack::Attack.cache.store = Rails.cache

  # 1分間制限
  throttle("api/urls/ip", limit: 10, period: 1.minute) do |req|
    if req.path.match?(%r{^/api/urls})
      req.ip
    end
  end

  # 1時間制限
  throttle("api/urls/ip/hour", limit: 100, period: 1.hour) do |req|
    if req.path.match?(%r{^/api/urls})
      req.ip
    end
  end

  # 1日制限
  throttle("api/urls/ip/day", limit: 1000, period: 1.day) do |req|
    if req.path.match?(%r{^/api/urls})
      req.ip
    end
  end

  self.throttled_responder = lambda do |req|
    data = req.env["rack.attack.match_data"]
    log_violation(data)
    build_response(data[:period])
  end

  private

  def self.log_violation(data)
    Rails.logger.warn(
      "Rate limit exceeded: #{data[:count]} requests " \
      "from #{data[:matched_ip]} in #{data[:period]}s"
    )
  end

  def self.build_response(period)
    [
      429,
      {
        "Content-Type" => "application/json; charset=utf-8",
        "Retry-After" => period.to_s
      },
      [{
        error: "Rate limit exceeded",
        message: "リクエストが多すぎます。しばらく待ってから再試行してください。",
        retry_after: period
      }.to_json]
    ]
  end
end
