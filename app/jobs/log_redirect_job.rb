class LogRedirectJob < ApplicationJob
  queue_as :default

  def initialize(
    redirect_log_service: RedirectLogService.new,
    shortened_url_repository: ShortenedUrlRepository.new
  )
    super()
    @redirect_log_service = redirect_log_service
    @shortened_url_repository = shortened_url_repository
  end

  def perform(shortened_url_id:, ip_address:, user_agent:, referer:)
    url = @shortened_url_repository.find_by_id(shortened_url_id)
    return unless url

    @redirect_log_service.create_redirect_log(
      url,
      ip_address: ip_address,
      user_agent: user_agent,
      referer: referer
    )
  end
end
