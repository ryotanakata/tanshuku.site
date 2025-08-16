require 'rails_helper'

RSpec.describe IpAddressService, type: :service do
  let(:service) { described_class.new }
  let(:mock_country_db) { instance_double(MaxMind::DB) }
  let(:mock_city_db) { instance_double(MaxMind::DB) }
  let(:mock_isp_db) { instance_double(MaxMind::DB) }

  before do
    allow(MaxMind::DB).to receive(:new).and_return(mock_country_db, mock_city_db, mock_isp_db)
    allow(Rails.logger).to receive(:error)
    allow(Rails.logger).to receive(:info)
  end

  describe '#extract_client_ip' do
    let(:request) { double('request') }

    context 'with X-Forwarded-For header' do
      before do
        allow(request).to receive(:env).and_return({
          'HTTP_X_FORWARDED_FOR' => '192.168.1.1, 10.0.0.1',
          'HTTP_X_REAL_IP' => '172.16.0.1'
        })
        allow(request).to receive(:ip).and_return('127.0.0.1')
      end

      it 'returns first IP from X-Forwarded-For' do
        result = service.extract_client_ip(request)
        expect(result).to eq('192.168.1.1')
      end
    end

    context 'with X-Real-IP header' do
      before do
        allow(request).to receive(:env).and_return({
          'HTTP_X_FORWARDED_FOR' => nil,
          'HTTP_X_REAL_IP' => '172.16.0.1'
        })
        allow(request).to receive(:ip).and_return('127.0.0.1')
      end

      it 'returns X-Real-IP when X-Forwarded-For is not present' do
        result = service.extract_client_ip(request)
        expect(result).to eq('172.16.0.1')
      end
    end

    context 'with no proxy headers' do
      before do
        allow(request).to receive(:env).and_return({
          'HTTP_X_FORWARDED_FOR' => nil,
          'HTTP_X_REAL_IP' => nil
        })
        allow(request).to receive(:ip).and_return('127.0.0.1')
      end

      it 'returns request.ip when no proxy headers are present' do
        result = service.extract_client_ip(request)
        expect(result).to eq('127.0.0.1')
      end
    end

    context 'with comma-separated X-Forwarded-For' do
      before do
        allow(request).to receive(:env).and_return({
          'HTTP_X_FORWARDED_FOR' => ' 203.0.113.1 , 10.0.0.1 ',
          'HTTP_X_REAL_IP' => nil
        })
        allow(request).to receive(:ip).and_return('127.0.0.1')
      end

      it 'strips whitespace from first IP' do
        result = service.extract_client_ip(request)
        expect(result).to eq('203.0.113.1')
      end
    end
  end

  describe '#overseas_ip?' do
    context 'with Japanese IP' do
      before do
        allow(mock_country_db).to receive(:get).with('203.0.113.1').and_return({
          'country' => { 'iso_code' => 'JP' }
        })
      end

      it 'returns false for Japanese IP' do
        result = service.overseas_ip?('203.0.113.1')
        expect(result).to be false
      end

      it 'logs the country information' do
        service.overseas_ip?('203.0.113.1')
        expect(Rails.logger).to have_received(:info).with('IP: 203.0.113.1, Country: JP')
      end
    end

    context 'with non-Japanese IP' do
      before do
        allow(mock_country_db).to receive(:get).with('8.8.8.8').and_return({
          'country' => { 'iso_code' => 'US' }
        })
      end

      it 'returns true for non-Japanese IP' do
        result = service.overseas_ip?('8.8.8.8')
        expect(result).to be true
      end

      it 'logs the country information' do
        service.overseas_ip?('8.8.8.8')
        expect(Rails.logger).to have_received(:info).with('IP: 8.8.8.8, Country: US')
      end
    end

    context 'with blank IP' do
      it 'returns false for nil IP' do
        expect(service.overseas_ip?(nil)).to be false
      end

      it 'returns false for empty IP' do
        expect(service.overseas_ip?('')).to be false
      end
    end

    context 'when database lookup fails' do
      before do
        allow(mock_country_db).to receive(:get).with('invalid-ip').and_raise(StandardError.new('Database error'))
      end

      it 'returns true and logs error' do
        result = service.overseas_ip?('invalid-ip')
        expect(result).to be true
        expect(Rails.logger).to have_received(:error).with('Error checking overseas IP invalid-ip: Database error')
      end
    end

    context 'with nil result from database' do
      before do
        allow(mock_country_db).to receive(:get).with('1.1.1.1').and_return(nil)
      end

      it 'returns true for nil result' do
        result = service.overseas_ip?('1.1.1.1')
        expect(result).to be true
      end
    end
  end

  describe '#lookup_geo_db' do
    let(:ip) { '203.0.113.1' }

    context 'with successful lookup' do
      before do
        allow(mock_country_db).to receive(:get).with(ip).and_return({
          'country' => { 'iso_code' => 'JP' }
        })
        allow(mock_city_db).to receive(:get).with(ip).and_return({
          'city' => { 'names' => { 'en' => 'Tokyo' } }
        })
        allow(mock_isp_db).to receive(:get).with(ip).and_return({
          'autonomous_system_organization' => 'NTT Communications'
        })
      end

      it 'returns complete geo information' do
        result = service.lookup_geo_db(ip)
        expect(result).to eq({
          country: 'JP',
          city: 'Tokyo',
          isp: 'NTT Communications'
        })
      end
    end

    context 'with partial lookup results' do
      before do
        allow(mock_country_db).to receive(:get).with(ip).and_return({
          'country' => { 'iso_code' => 'JP' }
        })
        allow(mock_city_db).to receive(:get).with(ip).and_return(nil)
        allow(mock_isp_db).to receive(:get).with(ip).and_return(nil)
      end

      it 'returns unknown for missing data' do
        result = service.lookup_geo_db(ip)
        expect(result).to eq({
          country: 'JP',
          city: 'unknown',
          isp: 'unknown'
        })
      end
    end

    context 'when lookup fails' do
      before do
        allow(mock_country_db).to receive(:get).with(ip).and_raise(StandardError.new('Database error'))
      end

      it 'returns unknown for all fields and logs error' do
        result = service.lookup_geo_db(ip)
        expect(result).to eq({
          country: 'unknown',
          city: 'unknown',
          isp: 'unknown'
        })
        expect(Rails.logger).to have_received(:error).with('Error looking up geo data for IP 203.0.113.1: Database error')
      end
    end

    context 'with nil results from databases' do
      before do
        allow(mock_country_db).to receive(:get).with(ip).and_return(nil)
        allow(mock_city_db).to receive(:get).with(ip).and_return(nil)
        allow(mock_isp_db).to receive(:get).with(ip).and_return(nil)
      end

      it 'returns unknown for all fields' do
        result = service.lookup_geo_db(ip)
        expect(result).to eq({
          country: 'unknown',
          city: 'unknown',
          isp: 'unknown'
        })
      end
    end
  end

  describe 'initialization' do
    context 'when MaxMind databases are available' do
      it 'initializes successfully' do
        expect { described_class.new }.not_to raise_error
      end
    end

    context 'when MaxMind databases fail to initialize' do
      before do
        allow(MaxMind::DB).to receive(:new).and_raise(StandardError.new('File not found'))
      end

      it 'raises an error' do
        expect { described_class.new }.to raise_error(StandardError, 'File not found')
      end
    end
  end
end
