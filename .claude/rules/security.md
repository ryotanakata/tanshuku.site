# セキュリティ規約（tanshuku）

## CSRF 対策

Rails の `protect_from_forgery` を必ず有効化する。

| ケース                      | 方法                                                                     |
| --------------------------- | ------------------------------------------------------------------------ |
| HTML フォーム（通常）       | Rails が自動で authenticity_token を埋め込む                             |
| React → API（Fetch / axios）| `<meta name="csrf-token">` を読み取り `X-CSRF-TOKEN` ヘッダーで送信     |

React 側の実装は `app/frontend/utils/internalApi.ts` のインターセプターが担う。新しい API クライアントを作る場合も同様に CSRF ヘッダーを付けること。

## 入力値の検証・サニタイズ

- Controller では `params.permit()` で許可するパラメータのみ抽出する（Strong Parameters）
- バリデーションロジックは `app/validators/` の Validator クラスに書く
- `eval` / `system` / `exec` へのユーザー入力の渡し込みは絶対禁止

## SQL インジェクション

- Active Record のメソッド（`find_by`, `where` 等）は必ずプレースホルダを使う
- 生 SQL が必要な場合は `ActiveRecord::Base.connection.execute(sanitize_sql_array([...]))` を使う

```ruby
# NG: 文字列補間（インジェクション可能）
User.where("email = '#{email}'")

# OK: プレースホルダ
User.where("email = ?", email)
User.where(email: email)
```

## 出力エスケープ

| 出力先                | 方法                                       |
| --------------------- | ------------------------------------------ |
| ERB テンプレート      | `<%= %>` の自動エスケープ（`<%== %>` は禁止） |
| JSON レスポンス       | `render json:` の Rails 自動エスケープ     |
| React `{ }` の展開   | JSX の自動エスケープ（`dangerouslySetInnerHTML` は禁止） |

## URL バリデーション

短縮対象 URL は以下を検証する：

- `http://` または `https://` で始まること
- 有効なドメイン名形式であること（IP アドレス直打ちは不可）
- ブロックリスト（`SiteConfig::BLOCKED_DOMAINS`）に含まれないこと
- 2048 文字以内であること

フロントエンド（Zod）とバックエンド（`ShortenedUrlValidator`）の両方で検証する。フロントエンドのみでは不十分。

## 地理的アクセス制限

`IpAddressService` が MaxMind DB で日本国内 IP を判定する。海外からのアクセスは Controller でブロックする。Cloudflare の `CF-Connecting-IP` ヘッダーを信頼する（`cloudflare-rails` gem で設定済み）。

## レートリミット

`rack-attack` で設定（`config/initializers/rack_attack.rb`）。POST /api/urls には特に厳しいレートリミットを設けている。新しいエンドポイントを追加したら rack-attack の設定も更新する。

## 機密情報の管理

- Rails credentials（`config/credentials.yml.enc`）または環境変数（`ENV`）で管理する
- シークレット情報をコードや Git にコミットしない
- `config/master.key` は `.gitignore` 対象

## Brakeman

コードを変更したら `bundle exec brakeman` を実行してセキュリティ警告がないか確認する。CI でも実行している。

## 依存パッケージの脆弱性

- `bundle audit` で Gem の既知脆弱性をチェックする
- `npm audit` で npm パッケージの既知脆弱性をチェックする

## ボット対策

短縮 URL のリダイレクト時に `CrawlerService` で User-Agent を検査し、クローラー・ボットからのアクセスをリダイレクトログに記録しない（またはスキップする）。
