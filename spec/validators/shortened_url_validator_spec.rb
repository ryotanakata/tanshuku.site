require 'rails_helper'

RSpec.describe ShortenedUrlValidator, type: :validator do
  let(:validator) { described_class.new }

  describe '#validate_creation!' do
    context 'with valid URLs' do
      it 'accepts valid HTTPS URLs' do
        expect { validator.validate_creation!('https://example.com') }.not_to raise_error
      end

      it 'accepts valid HTTP URLs' do
        expect { validator.validate_creation!('http://test.org') }.not_to raise_error
      end

      it 'accepts URLs with paths and query parameters' do
        expect { validator.validate_creation!('https://example.com/path?param=value') }.not_to raise_error
      end

      it 'accepts URLs with subdomains' do
        expect { validator.validate_creation!('https://subdomain.example.co.uk') }.not_to raise_error
      end
    end

    context 'with invalid URLs' do
      it 'rejects blank URLs' do
        expect { validator.validate_creation!('') }.to raise_error(ValidationError, /Validation failed: URLを入力してください/)
      end

      it 'rejects URLs without protocol' do
        expect { validator.validate_creation!('example.com') }.to raise_error(ValidationError, /Validation failed: http:\/\/またはhttps:\/\/から始まるURLを入力してください, 有効なドメインを含むURLを入力してください/)
      end

      it 'rejects URLs with invalid protocol' do
        expect { validator.validate_creation!('ftp://example.com') }.to raise_error(ValidationError, /Validation failed: http:\/\/またはhttps:\/\/から始まるURLを入力してください/)
      end

      it 'rejects URLs with IP addresses' do
        expect { validator.validate_creation!('https://192.168.1.1') }.to raise_error(ValidationError, /Validation failed: 有効なドメインを含むURLを入力してください/)
      end

      it 'rejects malformed URLs' do
        expect { validator.validate_creation!('not-a-url') }.to raise_error(ValidationError, /Validation failed: http:\/\/またはhttps:\/\/から始まるURLを入力してください, 有効なドメインを含むURLを入力してください/)
      end

      it 'rejects URLs that are too long' do
        long_url = 'https://example.com/' + 'a' * 2048
        expect { validator.validate_creation!(long_url) }.to raise_error(ValidationError, /Validation failed: URLが長すぎます（2048文字以内で入力してください）/)
      end
    end

    context 'with blocked domains' do
      it 'rejects URLs from blocked domains' do
        # frozen objectのため、直接テストする
        expect { validator.validate_creation!('https://tanshuku.site/page') }.to raise_error(ValidationError, /Validation failed: このURLは短縮できません/)
      end

      it 'rejects localhost URLs' do
        # localhostは複数のエラーが発生する可能性があるため、部分一致でテスト
        expect { validator.validate_creation!('http://localhost:3000') }.to raise_error(ValidationError, /このURLは短縮できません/)
      end
    end

    context 'with edge cases' do
      it 'handles URLs with underscores in domain' do
        expect { validator.validate_creation!('https://my_domain.com') }.to raise_error(ValidationError, /Validation failed: 有効なドメインを含むURLを入力してください/)
      end

      it 'handles URLs with trailing slashes' do
        expect { validator.validate_creation!('https://example.com/') }.not_to raise_error
      end

      it 'handles URLs with special characters in path' do
        # 特殊文字を含むパスは有効なURLとして扱われる
        expect { validator.validate_creation!('https://example.com/path-with-special-chars') }.not_to raise_error
      end
    end

    context 'error message format' do
      it 'includes all validation errors in the message' do
        expect { validator.validate_creation!('') }.to raise_error(ValidationError, /Validation failed: URLを入力してください/)
      end

      it 'handles multiple validation errors' do
        # プロトコルなし + 無効なドメイン
        expect { validator.validate_creation!('invalid-domain') }.to raise_error(ValidationError, /Validation failed: http:\/\/またはhttps:\/\/から始まるURLを入力してください, 有効なドメインを含むURLを入力してください/)
      end
    end
  end

  describe 'REGEX_HOST constant' do
    it 'matches valid hostnames' do
      valid_hosts = [
        'example.com',
        'sub.example.com',
        'my-domain.com',
        'example123.com',
        'a.b.c.d.e.f.com'
      ]

      valid_hosts.each do |host|
        expect(host).to match(ShortenedUrlValidator::REGEX_HOST)
      end
    end

    it 'does not match IP addresses' do
      invalid_hosts = [
        '192.168.1.1',
        '8.8.8.8',
        '127.0.0.1',
        '10.0.0.1'
      ]

      invalid_hosts.each do |host|
        expect(host).not_to match(ShortenedUrlValidator::REGEX_HOST)
      end
    end

    it 'does not match invalid hostnames' do
      invalid_hosts = [
        '-example.com',
        'example-.com',
        '.example.com',
        'example.com.',
        'example..com'
      ]

      invalid_hosts.each do |host|
        expect(host).not_to match(ShortenedUrlValidator::REGEX_HOST)
      end
    end
  end

  describe 'factory' do
    it 'has a valid factory' do
      expect(validator).to be_a(ShortenedUrlValidator)
    end
  end
end
