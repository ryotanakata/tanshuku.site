# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## 開発環境の起動

```bash
# Docker コンテナ起動（PostgreSQL）
docker-compose up -d

# 依存インストール
bundle install
npm install

# DB セットアップ
bin/rails db:create db:migrate

# 開発サーバ起動（Rails + Vite を同時起動）
bin/dev
```

- Rails アプリ: http://localhost:3000
- Vite dev サーバ: http://localhost:3036

環境変数は `.env` を作成して設定する（`DATABASE_URL` など）。

**主なコマンド**:

```bash
# フロントエンドビルド（本番）
npm run build

# テスト
bundle exec rspec

# セキュリティ検査
bundle exec brakeman

# コードフォーマット
npx prettier --write "app/frontend/**/*.{ts,tsx,scss}"
```

## ディレクトリ構成

```
app/
├── controllers/                 # プレゼンテーション層（薄い Controller）
│   ├── application_controller.rb
│   ├── pages_controller.rb      # ルートページ（React マウント先）
│   ├── redirects_controller.rb  # 短縮 URL リダイレクト
│   └── api/
│       ├── base_controller.rb   # API 共通基底クラス
│       └── urls_controller.rb   # POST /api/urls
├── models/                      # エンティティ（Active Record）
│   ├── shortened_url.rb
│   └── redirect_log.rb
├── services/                    # ビジネスロジック層
│   ├── shortened_url_service.rb
│   ├── redirect_log_service.rb
│   ├── crawler_service.rb
│   └── ip_address_service.rb
├── repositories/                # データアクセス層
│   ├── shortened_url_repository.rb
│   └── redirect_log_repository.rb
├── validators/                  # バリデーション層
│   └── shortened_url_validator.rb
├── exceptions/                  # カスタム例外クラス
├── frontend/                    # React + TypeScript（Vite で管理）
│   ├── entrypoints/
│   │   └── application.tsx      # Vite エントリポイント（React マウント）
│   ├── components/              # React コンポーネント
│   │   ├── Header/
│   │   ├── Footer/
│   │   └── Main/
│   │       ├── index.tsx
│   │       ├── style.module.scss
│   │       ├── Form/
│   │       └── Mv/
│   ├── pages/                   # ページコンポーネント
│   │   └── top/
│   │       └── page.tsx
│   ├── hooks/                   # カスタムフック
│   ├── schemas/                 # Zod バリデーションスキーマ
│   ├── constants/               # 定数
│   ├── types/                   # TypeScript 型定義
│   ├── utils/                   # 汎用ユーティリティ
│   └── styles/                  # グローバル SCSS
│       ├── style.scss           # エントリ（Foundation と Object を束ねる）
│       ├── Foundation/          # reset / base / variable / mixin / utility
│       └── Object/              # 再利用コンポーネントスタイル
└── views/
    ├── layouts/
    │   └── application.html.erb # <div id="root"> を持つシングルページ
    └── pages/
        └── index.html.erb       # React マウント先（ほぼ空）

config/
├── routes.rb                    # ルーティング定義
└── ...

spec/                            # RSpec テスト
├── controllers/
├── services/
├── repositories/
├── validators/
└── requests/
```

## アーキテクチャ概要

このリポジトリは「tanshuku」（国産 URL 短縮サービス）の Rails + React アプリを管理する。

### レンダリングフロー

Rails は SPA として動作する。`pages#index` が `application.html.erb` を返し、そこに React がマウントされる。

```
ブラウザ → GET /
  → PagesController#index
    → app/views/layouts/application.html.erb
      → <div id="root"> に Vite がバンドルした React をマウント
        → app/frontend/entrypoints/application.tsx
          → <TopPage /> をレンダリング
```

### URL 短縮フロー（フロントエンド → API）

```
Form コンポーネント（React）
  → POST /api/urls （X-CSRF-TOKEN ヘッダー付き）
    → Api::UrlsController#create
      → ShortenedUrlValidator#validate_creation!  （バリデーション）
      → ShortenedUrlService#create_shortened_url  （ビジネスロジック）
        → ShortenedUrlRepository#find_by_original_url  （既存チェック）
        → ShortenedUrlRepository#create                 （新規作成）
  → 短縮 URL を含む JSON を返す
```

### リダイレクトフロー

```
ブラウザ → GET /:short_code
  → RedirectsController#show
    → ShortenedUrlService#find_by_short_code
      → ShortenedUrlRepository#find_by_short_code
    → IpAddressService / CrawlerService でボット判定
    → RedirectLogService で記録
    → redirect_to original_url
```

### サービスリポジトリパターン

レイヤーの依存方向は一方向（Controller → Service → Repository → Model）。

| レイヤー   | 場所                  | 責務                                                     |
| ---------- | --------------------- | -------------------------------------------------------- |
| Controller | `app/controllers/`    | ルーティング・パラメータ抽出・レスポンス生成のみ         |
| Service    | `app/services/`       | ビジネスロジック。Active Record 操作は直接行わない       |
| Repository | `app/repositories/`   | Active Record を通じたデータアクセス。ビジネスロジック禁止 |
| Validator  | `app/validators/`     | ドメイン固有のバリデーション（形式・ルール）             |
| Model      | `app/models/`         | DB スキーマ定義・Active Record コールバック              |

Controller が Repository を直接呼ぶことは禁止。必ず Service を経由する。

### 依存性注入（DI）パターン

Service と Repository は **コンストラクタ DI** を使う。テスト時にモックを注入できる。

```ruby
class ShortenedUrlService
  def initialize(shortened_url_repository: ShortenedUrlRepository.new)
    @shortened_url_repository = shortened_url_repository
  end
end
```

### フロントエンドの CSRF 対策

Rails の CSRF トークンをメタタグ経由で React から取得する。`internalApi.ts` の axios インターセプターが自動でヘッダーに付与する。

```typescript
// app/frontend/utils/internalApi.ts
const token = document.querySelector<HTMLMetaElement>('meta[name="csrf-token"]')?.content;
config.headers["X-CSRF-TOKEN"] = token;
```

## 技術スタック

- Ruby 3.x / Rails 8.0
- PostgreSQL 15（Docker）
- React 19 + TypeScript
- Vite 7（vite_rails gem で統合）
- SCSS（Sass）+ CSS Modules
- React Hook Form 7 + Zod 4（フォームバリデーション）
- Axios（API クライアント）
- GSAP 3（アニメーション）
- RSpec 8（テスト）
- Brakeman（セキュリティ静的解析）
- Prettier 3（JS / TS / SCSS フォーマット）
- Cloudflare（CDN・セキュリティ）
- Railway（デプロイ）
- rack-attack（レートリミット）
- maxmind-db（IP ジオロケーション）
