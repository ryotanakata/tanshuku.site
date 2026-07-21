# Design

## 1. アーキテクチャ概要

コードレビュー指摘 13 件を 4 フェーズで修正する。
最優先はホットパスの性能（#1 メモ化・#2 非同期化）。
その後、セキュリティ（#3 IP・#4 海外遮断・#5 クローラー）、
データ整合（#6 一意制約・#7 deleted_at）、
品質（#8–#13 a11y・バージョン・テスト・CI）の順に着手する。

## 2. ディレクトリ構成（差分）

```
app/
├── jobs/
│   └── log_redirect_job.rb       ← 新規（#2）
├── services/
│   └── ip_address_service.rb     ← クラスメモ化（#1）・extract_client_ip 削除（#3）
├── controllers/
│   └── redirects_controller.rb   ← super() 追加・海外遮断・非同期ログ（#2, #3, #4）
├── repositories/
│   └── shortened_url_repository.rb ← deleted_at フィルタ追加（#7）
└── frontend/
    └── components/Main/Form/
        └── index.tsx              ← aria-label・aria-describedby（#9, #10）

app/views/layouts/
└── application.html.erb           ← lang="ja"（#8）

db/migrate/
└── YYYYMMDDXXXXXX_add_unique_index_to_shortened_urls_original_url.rb ← (#6)

public/
└── 403.html                       ← 海外遮断ページ（#4）

lib/
└── crawler_patterns.rb            ← SNS_PATTERNS 絞り込み（#5）

Dockerfile                         ← Ruby 3.4.3 に統一（#11）
package.json                       ← "typecheck": "tsc --noEmit" 追加（#13）
.github/workflows/ci.yml           ← npm run typecheck ステップ追加（#13）
```

## 3. 実装詳細

### Phase A: ホットパス修正（#1, #2, #3）

#### #1 IpAddressService — クラスレベルメモ化

MaxMind DB リーダーをクラスインスタンス変数にメモ化し、
プロセス起動時の初回のみ `MaxMind::DB.new` を呼ぶ。

```ruby
class IpAddressService
  class << self
    def country_db
      @country_db ||= MaxMind::DB.new(
        Rails.root.join("lib", "maxmind", "GeoLite2-Country.mmdb").to_s,
        mode: MaxMind::DB::MODE_MEMORY
      )
    end

    def city_db
      @city_db ||= MaxMind::DB.new(
        Rails.root.join("lib", "maxmind", "GeoLite2-City.mmdb").to_s,
        mode: MaxMind::DB::MODE_MEMORY
      )
    end

    def isp_db
      @isp_db ||= MaxMind::DB.new(
        Rails.root.join("lib", "maxmind", "GeoLite2-ASN.mmdb").to_s,
        mode: MaxMind::DB::MODE_MEMORY
      )
    end
  end

  def overseas_ip?(ip)
    return false if ip.blank?
    result = self.class.country_db.get(ip)
    result&.dig("country", "iso_code") != "JP"
  rescue => e
    Rails.logger.error "Error checking overseas IP #{ip}: #{e.message}"
    true
  end

  def lookup_geo_db(ip)
    country_result = self.class.country_db.get(ip)
    city_result    = self.class.city_db.get(ip)
    isp_result     = self.class.isp_db.get(ip)
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
```

`initialize` は削除（または空に）。テストは `allow(IpAddressService).to receive(:country_db).and_return(mock_db)` でモック。

#### #2 LogRedirectJob — 非同期ログ

```ruby
class LogRedirectJob < ApplicationJob
  queue_as :default

  def perform(shortened_url_id:, ip_address:, user_agent:, referer:, geo:)
    url = ShortenedUrl.find_by(id: shortened_url_id)
    return unless url

    RedirectLogService.new.create_log_from_job(url, ip_address, user_agent, referer, geo)
  end
end
```

`RedirectLogService` に `create_log_from_job` を追加（または `create_log` を引数ベースに変更）。

#### #3 IP ソース統一

`IpAddressService#extract_client_ip` を削除。
`RedirectsController` では `request.remote_ip`（cloudflare-rails が正しく解決済み）を直接使用。

### Phase B: セキュリティ修正（#4, #5）

#### #4 海外遮断

```ruby
# redirects_controller.rb の show 内
ip = request.remote_ip

if @ip_address_service.overseas_ip?(ip) && !@crawler_service.search_engine_crawler?(request.user_agent)
  render file: Rails.root.join("public/403.html"), status: :forbidden, layout: false
  return
end
```

`public/403.html` を作成（シンプルなエラーページ）。
SNS クローラー（OGP 取得）は `social_media_crawler?` が true でも既存フローへ。
検索エンジン bot は `search_engine_crawler?` が true なら遮断しない。

#### #5 SNS_PATTERNS 絞り込み

`lib/crawler_patterns.rb` の `SNS_PATTERNS` を、実在のプレビュー bot トークンのみに限定。
`social_media_crawler?` を語境界一致（`\b` 相当）に変更し、ブランド一般語の誤爆を防ぐ。

```ruby
SNS_PATTERNS = [
  "facebookexternalhit",
  "facebookcatalog",
  "twitterbot",
  "linkedinbot",
  "slackbot",
  "discordbot",
  "telegrambot",
  "whatsapp",
  "mastodon",
  "misskey",
  "hatena",
  "pinterest"
].freeze

# CrawlerService#social_media_crawler?
def social_media_crawler?(ua)
  return false if ua.blank?
  ua_lower = ua.downcase
  @sns_patterns.any? { |pattern| ua_lower.include?(pattern) }
end
```

除外するトークン: `line`, `instagram`, `amazon`, `youtube`, `rakuten`, `yahoo`, `naver`, `kakao`, `wechat`, `qq`, `weibo`, `note`, `tiktok`

### Phase C: データ整合（#6, #7）

#### #6 original_url 一意インデックス + 正規化

```ruby
# マイグレーション
add_index :shortened_urls, :original_url, unique: true, name: "idx_shortened_urls_original_url_unique"
```

`ShortenedUrlService#create_shortened_url` に `ActiveRecord::RecordNotUnique` の rescue を追加：

```ruby
def create_shortened_url(url)
  url = normalize_url(url)
  existing = @shortened_url_repository.find_by_original_url(url)
  return existing if existing

  @shortened_url_repository.create(
    original_url: url,
    short_code: generate_short_code
  )
rescue ActiveRecord::RecordNotUnique
  @shortened_url_repository.find_by_original_url(url)
end

private

def normalize_url(url)
  uri = URI.parse(url)
  uri.host = uri.host&.downcase
  uri.to_s.chomp("/")
rescue URI::InvalidURIError
  url.chomp("/")
end
```

#### #7 deleted_at フィルタ

`ShortenedUrlRepository` の検索メソッドに `deleted_at: nil` 条件を追加：

```ruby
def find_by_short_code(short_code)
  ShortenedUrl.where(deleted_at: nil).find_by(short_code: short_code.upcase)
end

def find_by_original_url(original_url)
  ShortenedUrl.where(deleted_at: nil).find_by(original_url: original_url)
end
```

テイクダウンは `url.update_column(:deleted_at, Time.current)` で実現（管理画面なしの最小実装）。

### Phase D: 品質（#8〜#13）

#### #8 lang 属性

```erb
<%# app/views/layouts/application.html.erb %>
<html lang="ja">
```

#### #9, #10 フォームアクセシビリティ

```tsx
{/* URL 入力 */}
<input
  id="url"
  aria-label="短縮したいURL"
  aria-describedby={errors.url ? "url-error" : undefined}
  aria-invalid={!!errors.url}
  {...register("url")}
/>
{errors.url && (
  <span id="url-error" role="alert">
    {errors.url.message}
  </span>
)}
```

#### #11 Ruby バージョン

```dockerfile
ARG RUBY_VERSION=3.4.3
```

#### #13 フロント型検査

```json
// package.json
"scripts": {
  "typecheck": "tsc --noEmit"
}
```

```yaml
# .github/workflows/ci.yml
- name: TypeScript type check
  run: npm run typecheck
```

## 4. データフロー（修正後のリダイレクト）

```
ブラウザ → GET /:short_code
  → RedirectsController#show
    → ShortenedUrlRepository#find_by_short_code  （deleted_at: nil 条件付き）
    → IpAddressService#overseas_ip?(request.remote_ip)
        ↑ クラスメモ化済み MaxMind DB を使用（プロセスあたり1回ロード）
    → 海外 && 非検索エンジン bot → 403 return
    → CrawlerService#social_media_crawler? → OGP render
    → redirect_to original_url, allow_other_host: true
    → LogRedirectJob.perform_later(...)  ← 非同期（リダイレクト後にキュー）
```

## 5. リスクと対策

| リスク | 対策 |
|---|---|
| original_url 一意制約で既存の重複行がマイグレーション失敗 | 事前に `SELECT original_url, COUNT(*) FROM shortened_urls GROUP BY original_url HAVING COUNT(*) > 1` で重複を確認・解消 |
| MaxMind クラスメモ化でテストが干渉 | `before` で `IpAddressService.instance_variable_set(:@country_db, nil)` をリセット |
| solid_queue ワーカー未起動でログが記録されない | `bin/dev` で Procfile に solid_queue を含める。ログ未記録は非クリティカル（リダイレクトは成功） |
| 海外遮断で正規ユーザーをブロック | Cloudflare の IP Geolocation が誤判定した場合は CF 側で adjust |
