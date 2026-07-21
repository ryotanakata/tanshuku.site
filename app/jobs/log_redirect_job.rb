class LogRedirectJob < ApplicationJob
  queue_as :default

  def perform(shortened_url_id:, ip_address:, user_agent:, referer:)
    url = ShortenedUrlRepository.new.find_by_id(shortened_url_id)
    return unless url

    RedirectLogService.new.create_redirect_log(
      url,
      ip_address: ip_address,
      user_agent: user_agent,
      referer: referer
    )
  end
end
