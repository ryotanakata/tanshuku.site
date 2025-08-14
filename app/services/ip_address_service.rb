require 'maxmind/db'

class IpAddressService
  def initialize
    @maxmind_country = MaxMind::DB.new(Rails.root.join('lib', 'maxmind', 'GeoLite2-Country.mmdb').to_s, mode: MaxMind::DB::MODE_MEMORY)
    @maxmind_city = MaxMind::DB.new(Rails.root.join('lib', 'maxmind', 'GeoLite2-City.mmdb').to_s, mode: MaxMind::DB::MODE_MEMORY)
    @maxmind_isp = MaxMind::DB.new(Rails.root.join('lib', 'maxmind', 'GeoLite2-ASN.mmdb').to_s, mode: MaxMind::DB::MODE_MEMORY)
  rescue => e
    Rails.logger.error "Failed to initialize MaxMind databases: #{e.message}"
    raise
  end

  def extract_client_ip(request)
    x_forwarded_for = request.env['HTTP_X_FORWARDED_FOR']
    x_real_ip = request.env['HTTP_X_REAL_IP']

    return x_forwarded_for.split(',').first.strip if x_forwarded_for.present?
    return x_real_ip if x_real_ip.present?

    request.ip
  end

  def overseas_ip?(ip)
    return false if ip.blank?

    begin
      result = @maxmind_country.get(ip)
      Rails.logger.info "IP: #{ip}, Country: #{result&.dig('country', 'iso_code')}"
      result&.dig('country', 'iso_code') != 'JP'
    rescue => e
      Rails.logger.error "Error checking overseas IP #{ip}: #{e.message}"
      true
    end
  end

  def lookup_geo_db(ip)
    begin
      country_result = @maxmind_country.get(ip)
      city_result = @maxmind_city.get(ip)
      isp_result = @maxmind_isp.get(ip)

      {
        country: country_result&.dig('country', 'iso_code') || "unknown",
        city: city_result&.dig('city', 'names', 'en') || "unknown",
        isp: isp_result&.dig('autonomous_system_organization') || "unknown"
      }
    rescue => e
      Rails.logger.error "Error looking up geo data for IP #{ip}: #{e.message}"
      {
        country: "unknown",
        city: "unknown",
        isp: "unknown"
      }
    end
  end
end