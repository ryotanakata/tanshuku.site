class RedirectLogService
  def initialize(
    redirect_log_repository: RedirectLogRepository.new,
    ip_address_service: IpAddressService.new
  )
    @redirect_log_repository = redirect_log_repository
    @ip_address_service = ip_address_service
  end

  def create_redirect_log(url, ip_address:, user_agent:, referer:)
    if @ip_address_service.overseas_ip?(ip_address)
      create_anonymous_log(url)
    else
      geo = @ip_address_service.lookup_geo_db(ip_address)
      create_log(url, ip_address: ip_address, user_agent: user_agent, referer: referer, geo: geo)
    end
  end

  def create_log(url, ip_address:, user_agent:, referer:, geo:)
    @redirect_log_repository.create_log({
      shortened_url: url,
      ip_address: ip_address || "unknown",
      country: geo[:country],
      city: geo[:city],
      isp: geo[:isp],
      user_agent: user_agent || "unknown",
      referer: referer || "unknown"
    })
  end

  def create_anonymous_log(url)
    @redirect_log_repository.create_log({
      shortened_url: url,
      ip_address: "unknown",
      country: "unknown",
      city: "unknown",
      isp: "unknown",
      user_agent: "unknown",
      referer: "unknown"
    })
  end
end
