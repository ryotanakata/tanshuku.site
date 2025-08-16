# tanshuku

「tanshuku」は2025年8月にリリースされた国産URL短縮サービス。シンプルで使いやすく、日本国内で安心してご利用いただけます。

![Screenshot of custom video player UI](https://github.com/ryotanakata/tanshuku.site/raw/master/screenshot.gif)

## 特徴

### 🇯🇵 日本国内からのみアクセス可能

海外からのアクセスをブロックし、日本国内でのみサービスを提供することで、セキュリティとプライバシーを保護しています。

## 技術スタック

- **バックエンド**: Ruby on Rails
- **フロントエンド**: React, TypeScript
- **データベース**: PostgreSQL
- **アセットパイプライン**: Vite
- **スタイリング**: SCSS
- **デプロイ**: Railway
- **コンテナ**: Docker

## 設計思想

### クリーンアーキテクチャ

ビジネスロジック、データアクセス、プレゼンテーションを明確に分離し、内側の層が外側の層に依存しない単方向の依存関係を実現。

### サービスリポジトリパターン

ビジネスロジックをサービス層に集約し、データアクセスをリポジトリ層で抽象化することで、保守性とテスタビリティを向上。

### セキュリティ

地理的制限による海外アクセスブロック、厳密な入力検証、詳細なアクセスログ記録により、セキュリティを強化。

## プロジェクト構成

```
app                         　　　　　 # Rails アプリケーション
├── controllers/             　　　　　# プレゼンテーション層
│   ├── api/                 　　　　　# API コントローラー
│   │   ├── base_controller.rb
│   │   └── urls_controller.rb
│   ├── application_controller.rb
│   ├── pages_controller.rb
│   └── redirects_controller.rb
├── models/                  　　　　　# エンティティ
│   ├── shortened_url.rb
│   └── redirect_log.rb
├── services/                　　　　　# ビジネスロジック層
│   ├── shortened_url_service.rb
│   ├── redirect_log_service.rb
│   ├── crawler_service.rb
│   └── ip_address_service.rb
├── repositories/            　　　　　# データアクセス層
│   ├── shortened_url_repository.rb
│   └── redirect_log_repository.rb
├── validators/              　　　　　# バリデーション層
│   └── shortened_url_validator.rb
├── frontend/                　　　　　# React フロントエンド
│   ├── components/          　　　　　# React コンポーネント
│   │   ├── Header/
│   │   ├── Main/
│   │   └── Footer/
│   ├── pages/               　　　　　# ページコンポーネント
│   ├── styles/              　　　　　# SCSS スタイル
│   └── types/               　　　　　# TypeScript 型定義
└── views/                   　　　　　# Rails ビュー
    ├── layouts/
    └── pages/
config/                      　　　　　# 設定ファイル
db/                          　　　　　# データベース関連
lib/                         　　　　　# ライブラリ
spec/                        　　　　　# テスト
```
