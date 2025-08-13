# Tanshuku.site

短縮 URL サービスを提供する Web アプリケーションです。

## 技術スタック

- **Backend**: Ruby on Rails 8.0.2
- **Frontend**: React 19 + TypeScript
- **Database**: PostgreSQL 15
- **Asset Pipeline**: Vite
- **Styling**: SCSS
- **Deployment**: Railway

## 前提条件

- Ruby 3.2 以上
- Node.js 18 以上
- Docker & Docker Compose

## セットアップ

### 1. リポジトリのクローン

```bash
git clone <repository-url>
cd tanshuku.site
```

### 2. 依存関係のインストール

```bash
# Ruby依存関係
bundle install

# Node.js依存関係
npm install
```

### 3. データベースのセットアップ

```bash
# PostgreSQLコンテナを起動
docker-compose up -d db

# データベースの作成とセットアップ
bin/rails db:prepare
```

## 開発サーバーの起動

```bash
# 開発サーバーを起動（Rails + Vite + その他）
bin/dev
```

これにより以下が同時に起動します：

- Rails サーバー（ポート 3000）
- Vite 開発サーバー
- その他の開発サービス

## よく使用するコマンド

### データベース関連

```bash
# データベースの作成
bin/rails db:create

# マイグレーションの実行
bin/rails db:migrate

# データベースのリセット
bin/rails db:reset

# シードデータの投入
bin/rails db:seed
```

### 開発・テスト関連

```bash
# コードの品質チェック
bin/rubocop

# セキュリティチェック
bin/brakeman

# テストの実行
bin/rails test

# コンソールの起動
bin/rails console
```

### アセット関連

```bash
# フロントエンドアセットのビルド
npm run build

# Tailwind CSSのビルド
npm run build:css

# Vite開発サーバーの起動
npm run dev
```

## 開発環境のセットアップ（一括）

```bash
# 全セットアップを実行（依存関係のインストール、DBセットアップ、サーバー起動）
bin/setup
```

## ポート設定

- **Rails**: 3000
- **PostgreSQL**: 5432
- **Vite**: 5173（開発時）

## トラブルシューティング

### よくある問題

1. **ポートが既に使用されている場合**

   ```bash
   # 使用中のポートを確認
   lsof -i :3000

   # プロセスを終了
   kill -9 <PID>
   ```

2. **データベース接続エラー**

   ```bash
   # PostgreSQLコンテナの状態確認
   docker-compose ps

   # コンテナを再起動
   docker-compose restart db
   ```

3. **Node.js 依存関係の問題**

   ```bash
   # node_modulesを削除して再インストール
   rm -rf node_modules package-lock.json
   npm install
   ```

## デプロイ

main ブランチにマージすると、Railway で自動的にデプロイされます。
