require "maxmind/db"

class IpAddressService
  class << self
    def country_db
      @country_db ||= MaxMind::DB.new(
        Rails.root.join("lib", "maxmind", "GeoLite2-Country.mmdb").to_s,
        mode: MaxMind::DB::MODE_MEMORY
      )
    rescue => e
      Rails.logger.error "Failed to load MaxMind Country DB: #{e.message}"
      raise
    end

    def city_db
      @city_db ||= MaxMind::DB.new(
        Rails.root.join("lib", "maxmind", "GeoLite2-City.mmdb").to_s,
        mode: MaxMind::DB::MODE_MEMORY
      )
    rescue => e
      Rails.logger.error "Failed to load MaxMind City DB: #{e.message}"
      raise
    end

    def isp_db
      @isp_db ||= MaxMind::DB.new(
        Rails.root.join("lib", "maxmind", "GeoLite2-ASN.mmdb").to_s,
        mode: MaxMind::DB::MODE_MEMORY
      )
    rescue => e
      Rails.logger.error "Failed to load MaxMind ISP DB: #{e.message}"
      raise
    end
  end

  def initialize
    @maxmind_country = self.class.country_db
    @maxmind_city    = self.class.city_db
    @maxmind_isp     = self.class.isp_db
  end

  def overseas_ip?(ip)
    return false if ip.blank?

    begin
      result = @maxmind_country.get(ip)
      country_code = result&.dig("country", "iso_code")
      Rails.logger.info "IP: #{ip}, Country: #{country_code}"
      return false if country_code.nil?

      country_code != "JP"
    rescue => e
      Rails.logger.error "Error checking overseas IP #{ip}: #{e.message}"
      true
    end
  end

  def lookup_geo_db(ip)
    begin
      country_result = @maxmind_country.get(ip)
      city_result    = @maxmind_city.get(ip)
      isp_result     = @maxmind_isp.get(ip)

      {
        country: country_result&.dig("country", "iso_code") || "unknown",
        city:    city_result&.dig("city", "names", "en")    || "unknown",
        isp:     isp_result&.dig("autonomous_system_organization") || "unknown"
      }
    rescue => e
      Rails.logger.error "Error looking up geo data for IP #{ip}: #{e.message}"
      { country: "unknown", city: "unknown", isp: "unknown" }
    end
  end
end
