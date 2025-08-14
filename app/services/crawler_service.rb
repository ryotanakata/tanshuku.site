require 'crawler_patterns'

class CrawlerService
  def initialize
    @patterns = CrawlerPatterns::PATTERNS
  end

  def search_engine_crawler?(ua)
    return false if ua.blank?

    ua_lower = ua.downcase

    @patterns.values.flatten.any? do |pattern|
      ua_lower.include?(pattern)
    end
  end

  def identify_crawler(ua)
    return nil if ua.blank?

    ua_lower = ua.downcase

    @patterns.each do |type, patterns|
      patterns.each do |pattern|
        return type.to_s if ua_lower.include?(pattern)
      end
    end

    nil
  end

  def should_allow_crawler?(ua)
    return true if ua.blank?

    search_engine_crawler?(ua)
  end

  def log_crawler_access(ua, ip)
    crawler = identify_crawler(ua)

    if crawler
      Rails.logger.info "Crawler access: #{crawler} (#{ua}) from #{ip}"
    end
  end
end
