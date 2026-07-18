# バックエンド規約（tanshuku）

## Ruby / Rails

- Ruby 3.x + Rails 8.0 の構文・慣習に従う
- クラスファイルは 1 ファイル 1 クラス
- メソッドは 10 行以内を目標。複雑な処理は private メソッドに分割する

**ファイル名・クラス名の命名規則**

ファイル名はスネークケース。クラス名はアッパーキャメルケース（Rails 規約）。

| ディレクトリ        | サフィックス   | ファイル名例                        | クラス名例                  |
| ------------------- | -------------- | ----------------------------------- | --------------------------- |
| `app/controllers/`  | `Controller`   | `urls_controller.rb`                | `Api::UrlsController`       |
| `app/services/`     | `Service`      | `shortened_url_service.rb`          | `ShortenedUrlService`       |
| `app/repositories/` | `Repository`   | `shortened_url_repository.rb`       | `ShortenedUrlRepository`    |
| `app/validators/`   | `Validator`    | `shortened_url_validator.rb`        | `ShortenedUrlValidator`     |
| `app/exceptions/`   | `Error`        | `validation_error.rb`               | `ValidationError`           |
| `app/models/`       | なし           | `shortened_url.rb`                  | `ShortenedUrl`              |

API コントローラーは `app/controllers/api/` に置き、`Api::` モジュールで名前空間を付ける（例: `Api::UrlsController`）。メソッド名はスネークケース。

## レイヤー責務分離

Controller → Service → Repository → Model の一方向依存のみ許可。

| レイヤー   | 場所                  | 書いてよいこと                                         | 書いてはいけないこと                      |
| ---------- | --------------------- | ------------------------------------------------------ | ----------------------------------------- |
| Controller | `app/controllers/`    | params 抽出・Validator 呼び出し・Service 呼び出し・render/redirect | ビジネスロジック・直接の DB アクセス  |
| Service    | `app/services/`       | ビジネスロジック・Repository 呼び出し・例外送出        | Controller への参照・直接の Active Record |
| Repository | `app/repositories/`   | Active Record を通じた CRUD                            | ビジネスロジック                          |
| Validator  | `app/validators/`     | フォーマット検証・ドメインルール検証・例外送出         | DB アクセス・ビジネスロジック            |
| Model      | `app/models/`         | DB スキーマ定義・Active Record バリデーション・スコープ | ビジネスロジック |

**Controller が Repository を直接呼ぶことは禁止。必ず Service を経由する。**

## Controller

### 実装パターン

```ruby
# app/controllers/api/urls_controller.rb
module Api
  class UrlsController < BaseController
    def initialize(
      shortened_url_service: ShortenedUrlService.new,
      shortened_url_validator: ShortenedUrlValidator.new
    )
      @shortened_url_service = shortened_url_service
      @shortened_url_validator = shortened_url_validator
    end

    def create
      original_url = url_params[:url]

      @shortened_url_validator.validate_creation!(original_url)
      shortened_url = @shortened_url_service.create_shortened_url(original_url)

      render json: {
        original_url: shortened_url.original_url,
        short_code: shortened_url.short_code
      }, status: :created
    end

    private

    def url_params
      params.permit(:url)
    end
  end
end
```

**Controller に書いてよいこと**:
- `params.permit()` による Strong Parameters の抽出（private メソッド `xxx_params` に切り出す）
- Validator の呼び出し（`!` メソッドで例外を発生させる）
- Service の呼び出し
- `render json:` / `redirect_to` によるレスポンス生成

Controller が 30 行を超えたら Service に逃がす。

## API エラーハンドリング（`Api::BaseController`）

`Api::BaseController` が `rescue_from` で例外を一括ハンドリングする。**個々のコントローラーで rescue_from を書かない**。

```ruby
# app/controllers/api/base_controller.rb
module Api
  class BaseController < ApplicationController
    rescue_from StandardError,                        with: :handle_standard_error
    rescue_from ActiveRecord::RecordNotFound,         with: :handle_not_found
    rescue_from ActionController::ParameterMissing,   with: :handle_parameter_missing
    rescue_from ValidationError,                      with: :handle_validation_error
    rescue_from ShortenedUrlCreationError,            with: :handle_creation_error
  end
end
```

| 例外クラス | HTTP ステータス | レスポンス形式 |
|---|---|---|
| `ValidationError` | 422 | `{ errors: ["エラーメッセージ"] }` |
| `ShortenedUrlCreationError` | 422 | `{ errors: ["エラーメッセージ"] }` |
| `ActiveRecord::RecordNotFound` | 404 | `{ error: "Resource not found" }` |
| `ActionController::ParameterMissing` | 400 | `{ error: "Missing parameter: ..." }` |
| `StandardError` | 500 | `{ error: "Internal server error" }` |

新しいカスタム例外を追加したら `Api::BaseController` の `rescue_from` も追加する。

## 依存性注入（DI）パターン

**全ての Service・Repository・Controller でコンストラクタ DI を使う**。デフォルト値にインスタンスを渡すことで、呼び出し側は通常コンストラクタ引数なしで使え、テスト時にモックを注入できる。

```ruby
class ShortenedUrlService
  def initialize(shortened_url_repository: ShortenedUrlRepository.new)
    @shortened_url_repository = shortened_url_repository
  end
end

# 通常利用（引数なし）
service = ShortenedUrlService.new

# テスト（モック注入）
service = ShortenedUrlService.new(shortened_url_repository: mock_repository)
```

複数の依存を注入する場合は Controller の例に倣い、キーワード引数で列挙する。

## カスタム例外

`app/exceptions/` にカスタム例外を置く。`StandardError` を継承し、`@errors` 配列で複数エラーを保持する。

```ruby
class ValidationError < StandardError
  attr_reader :errors

  def initialize(errors)
    @errors = errors
    super("Validation failed: #{errors.join(', ')}")
  end
end

class ShortenedUrlCreationError < StandardError
  attr_reader :errors

  def initialize(errors)
    @errors = errors
    super("Failed to create shortened URL: #{errors.join(', ')}")
  end
end
```

- `errors` は文字列の配列（日本語メッセージ）
- `Api::BaseController` の `rescue_from` が `exception.errors` を JSON に変換する

## Validator

`validate_xxx!` の bang メソッドで呼び出す。失敗時は `raise ValidationError.new(errors)` で例外を送出する。**エラーを早期 return せず、全エラーを収集してから一括で raise する**。

```ruby
class ShortenedUrlValidator
  REGEX_HOST = /^(?!\d+\.\d+\.\d+\.\d+$)[...]+$/

  def validate_creation!(url)
    errors = []

    if url.blank?
      errors << "URLを入力してください"
    else
      begin
        uri = URI.parse(url)
        errors << "http://またはhttps://..." unless uri.scheme&.match?(/^https?$/)
        errors << "有効なドメインを..." unless uri.host&.match?(REGEX_HOST)
        errors << "このURLは短縮できません" if blocked?(uri.host)
      rescue URI::InvalidURIError
        errors << "無効なURL形式です"
      end
    end

    errors << "URLが長すぎます..." if url.present? && url.length > 2048

    raise ValidationError.new(errors) unless errors.empty?
  end
end
```

- Validator は DB アクセスをしない（`SiteConfig::BLOCKED_DOMAINS` 等の定数参照は許可）
- 正規表現定数はクラス定数として定義する（例: `REGEX_HOST`）

## Service

- ビジネスロジックを担う。Active Record のメソッドを直接呼ばず Repository を経由する
- `unless record.persisted?` で保存失敗を検知して専用の例外を raise する
- 末尾スラッシュの正規化など、ドメイン固有の前処理もここで行う

```ruby
class ShortenedUrlService
  def create_shortened_url(url)
    url = url.chomp("/") if url.end_with?("/")          # 前処理
    existing = @repo.find_by_original_url(url)
    return existing if existing                          # 冪等性

    record = @repo.create(
      original_url: url,
      short_code: generate_short_code,
      created_at: Time.current
    )

    unless record.persisted?
      raise ShortenedUrlCreationError.new(record.errors.full_messages)
    end

    record
  end

  private

  def generate_short_code
    loop do
      code = SecureRandom.alphanumeric(6).upcase
      break code unless @repo.exists?(code)            # 衝突回避
    end
  end
end
```

## Repository

Active Record CRUD のみ。ビジネスロジックを持たない。

```ruby
class ShortenedUrlRepository
  def create(attributes)
    record = ShortenedUrl.new(attributes)
    record.save
    record
  end

  def find_by_short_code(short_code)
    ShortenedUrl.find_by(short_code: short_code.upcase)   # 大文字正規化
  end

  def exists?(short_code)
    ShortenedUrl.exists?(short_code: short_code.upcase)
  end

  def delete(id)
    ShortenedUrl.find(id).destroy
  rescue ActiveRecord::RecordNotFound
    false
  end
end
```

- 検索キーは大文字に正規化してから Active Record に渡す（`upcase`）
- `delete` の `ActiveRecord::RecordNotFound` は Repository 内で rescue して `false` を返す（呼び出し元を複雑にしない）
- `create!` ではなく `save` → `persisted?` のパターンで作成失敗を Service 側に返す

## Model

DB スキーマ・バリデーション・アソシエーション・スコープのみ。ビジネスロジックは書かない。

```ruby
class ShortenedUrl < ApplicationRecord
  validates :original_url, presence: true
  validates :short_code,   presence: true, uniqueness: true, length: { is: 6 }

  has_many :redirect_logs, dependent: :destroy
end

class RedirectLog < ApplicationRecord
  belongs_to :shortened_url
  validates  :shortened_url, presence: true

  scope :recent,        -> { where("created_at > ?", 30.days.ago) }
  scope :by_date,       ->(date) { where("DATE(created_at) = ?", date) }
  scope :japanese_only, -> { where.not(ip_address: nil) }
end
```

- よく使うクエリは `scope` として定義する
- スコープに複雑なビジネスロジックを入れない

## テスト（RSpec）

### テストタイプと DB の使い方

| 対象 | spec の場所 | `type:` | DB 使用 |
|---|---|---|---|
| Service | `spec/services/` | `:service` | しない（Repository を `instance_double` でモック） |
| Repository | `spec/repositories/` | `:repository` | する（実際の DB を使う） |
| Validator | `spec/validators/` | `:validator` | しない |
| Request | `spec/requests/` | `:request` | する |

### Service テストのパターン（Repository をモック）

```ruby
RSpec.describe ShortenedUrlService, type: :service do
  let(:repository) { instance_double(ShortenedUrlRepository) }
  let(:service)    { described_class.new(shortened_url_repository: repository) }

  describe '#create_shortened_url' do
    it 'returns existing URL if already registered' do
      allow(repository).to receive(:find_by_original_url).and_return(existing_url)
      expect(service.create_shortened_url(url)).to eq(existing_url)
    end

    it 'raises ShortenedUrlCreationError when save fails' do
      allow(repository).to receive(:find_by_original_url).and_return(nil)
      allow(repository).to receive(:exists?).and_return(false)
      allow(repository).to receive(:create).and_return(unsaved_record)
      allow(unsaved_record).to receive(:persisted?).and_return(false)
      allow(unsaved_record).to receive(:errors).and_return(double(full_messages: ["error"]))

      expect { service.create_shortened_url(url) }.to raise_error(ShortenedUrlCreationError)
    end
  end
end
```

### Repository テストのパターン（実 DB を使う）

```ruby
RSpec.describe ShortenedUrlRepository, type: :repository do
  let(:repository) { described_class.new }

  describe '#find_by_short_code' do
    let!(:record) { ShortenedUrl.create!(original_url: 'https://example.com', short_code: 'ABC123') }

    it 'finds by lowercase code too' do
      expect(repository.find_by_short_code('abc123')).to eq(record)
    end
  end
end
```

- Repository テストは Factory Bot を使わず `Model.create!` を直接呼ぶ
- Service テストで `SecureRandom` のような外部依存もスタブしてよい

### Validator テストのパターン（例外をマッチ）

```ruby
RSpec.describe ShortenedUrlValidator, type: :validator do
  let(:validator) { described_class.new }

  it 'raises ValidationError with message for blank URL' do
    expect { validator.validate_creation!('') }
      .to raise_error(ValidationError, /URLを入力してください/)
  end

  it 'collects multiple errors at once' do
    expect { validator.validate_creation!('invalid-domain') }
      .to raise_error(ValidationError, /http:\/\/.*https:\/\/.*有効なドメイン/)
  end
end
```

## レートリミット（Rack::Attack）

`config/initializers/rack_attack.rb` に集約する。現在の制限:

| ルール名 | 対象パス | 制限 |
|---|---|---|
| `api/urls/ip` | `/api/urls*` | 10 req / 分 |
| `api/urls/ip/hour` | `/api/urls*` | 100 req / 時間 |
| `api/urls/ip/day` | `/api/urls*` | 1000 req / 日 |

制限超過時は 429 に `Retry-After` ヘッダーと日本語メッセージを含む JSON を返す。新しいエンドポイントを追加したらここに制限を追加する。

## 特殊ケース：クローラー対応（RedirectsController）

`RedirectsController#show` はリダイレクト処理の中でクローラー判定を行う。

| クローラー種別 | 処理 |
|---|---|
| 検索エンジン（Googlebot 等） | 通常通りリダイレクト。ログに `Crawler access` を記録 |
| SNS クローラー（OGP 取得） | `pages/ogp` ビューを render してリダイレクトしない |
| 海外 IP からのアクセス | 匿名ログ（IP・国・都市を `"unknown"` で記録）を作成してからリダイレクト |

ログ作成の失敗（`rescue => e`）はリダイレクト処理全体を止めない（`Rails.logger.error` のみ）。
