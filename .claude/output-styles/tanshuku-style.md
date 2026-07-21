# tanshuku 返答スタイル

tanshuku（Rails + React URL 短縮サービス）の開発を前提とした返答ルール。

## コードの示し方

修正案は NG/OK の対比で示す：

```ruby
# NG: Controller が Repository を直接呼ぶ
class Api::UrlsController < BaseController
  def create
    url = ShortenedUrl.find_by(original_url: params[:url])
  end
end

# OK: Controller → Service → Repository の順で委譲
class Api::UrlsController < BaseController
  def create
    url = url_params[:url]
    @shortened_url_validator.validate_creation!(url)
    shortened_url = @shortened_url_service.create_shortened_url(url)
    render json: { ... }, status: :created
  end
end
```

ファイル参照は markdown link 形式で示す（VSCode 拡張で開けるように）：

- ファイル: [urls_controller.rb](app/controllers/api/urls_controller.rb)
- 行指定: [shortened_url_service.rb:15](app/services/shortened_url_service.rb#L15)
- 範囲指定: [internalApi.ts:1-30](app/frontend/utils/internalApi.ts#L1-L30)

バッククォートや `<code>` での疑似リンクは使わない。

## レビュー返答

1. **設計の良い点を必ず1点挙げる**（レイヤー分離・DI パターン等）
2. 問題点は重要度順（🔴 Critical → 🟡 Warning → 🔵 Info）で列挙する
3. 問題が属する層を以下のように明示する：
   - `[Controller 層]`
   - `[Service 層]`
   - `[Repository 層]`
   - `[Validator 層]`
   - `[Model 層]`
   - `[フロントエンド - Component]`
   - `[フロントエンド - Hooks]`
   - `[フロントエンド - Schema]`
4. **Critical と Warning が無ければ「指摘なし」と明言する**（Info で水増ししない）

## 実装提案

1. **どの層に追加するかを最初に宣言する**：
   - ビジネスロジック → `app/services/{name}_service.rb`
   - データアクセス → `app/repositories/{name}_repository.rb`
   - バリデーション → `app/validators/{name}_validator.rb`
   - API エンドポイント → `app/controllers/api/{name}s_controller.rb`
   - React コンポーネント → `app/frontend/components/{Name}/index.tsx`
   - カスタムフック → `app/frontend/hooks/use{Name}.ts`
2. Controller → Service → Repository の一方向依存を守る
3. Service と Repository は **コンストラクタ DI** パターンで実装する
4. フロントエンドの CSRF トークン付与は `internalApi.ts` のインターセプターが自動で行うため、呼び出し元では意識しないと明示する
5. スタイルを編集した場合は「**`npm run build` でビルドが必要**」と末尾に添える

## 調査・探索系の返答

- 結論を1文で先に述べてから根拠を示す
- 根拠ファイルは [filename:行番号](path#L行番号) の markdown link で示す
- バックエンド（`app/services/` 等）とフロントエンド（`app/frontend/`）のどちらを参照したかを明示する
- 新しい API エンドポイントに関わる変更では、[rack_attack 設定](config/initializers/rack_attack.rb) の確認も促す

## 動作確認の伝え方

- dev 時: 「`bin/dev` を起動した状態で `http://localhost:3000` で目視確認してください」
- prod 時: 「`npm run build` → Rails サーバ再起動 → `http://localhost:3000` で目視確認してください」
- テスト: 「`bundle exec rspec {spec_path}` で確認してください」
- セキュリティ: 「`bundle exec brakeman` で警告がないことを確認してください」
- PostgreSQL は `docker-compose up -d` で `localhost:5432` に起動
