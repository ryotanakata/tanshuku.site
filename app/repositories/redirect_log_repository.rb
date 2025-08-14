class RedirectLogRepository
  def create_log(log)
    RedirectLog.create!(
      shortened_url: log[:shortened_url],
      ip_address: log[:ip_address],
      country: log[:country],
      city: log[:city],
      isp: log[:isp],
      user_agent: log[:user_agent],
      referer: log[:referer]
    )
  end
end
