class RedirectLogService
  def initialize(redirect_log_repository: RedirectLogRepository.new)
    @redirect_log_repository = redirect_log_repository
  end

  def create_log(url, request, geo)
    log = {
      shortened_url: url,
      ip_address: request.remote_ip || "unknown",
      country: geo[:country],
      city: geo[:city],
      isp: geo[:isp],
      user_agent: request.user_agent || "unknown",
      referer: request.referer || "unknown"
    }
    @redirect_log_repository.create_log(log)
  end

  def create_anonymous_log(url, request)
    log = {
      shortened_url: url,
      ip_address: "unknown",
      country: "unknown",
      city: "unknown",
      isp: "unknown",
      user_agent: "unknown",
      referer: "unknown"
    }
    @redirect_log_repository.create_log(log)
  end
end
