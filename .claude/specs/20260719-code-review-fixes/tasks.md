# Tasks

[design.md](design.md) に従い **Phase A → B → C → D** で進める。
各タスク完了で `[x]`。目視確認は `http://localhost:3000` で行う。

---

## Phase 0: 事前確認

- [x] Docker が起動していることを確認（`docker-compose up -d`）
- [x] Rails サーバが起動していることを確認（`bin/dev`）
- [x] `bundle exec rspec` で既存テストが全て通ることを確認
- [x] `SELECT original_url, COUNT(*) FROM shortened_urls GROUP BY original_url HAVING COUNT(*) > 1;` で重複行がないことを確認

---

## Phase A: ホットパス修正（#1, #2, #3）

- [x] `app/services/ip_address_service.rb` — `class << self` でクラスメモ化、`initialize` 削除、`extract_client_ip` 削除
- [x] `app/jobs/log_redirect_job.rb` — 新規作成（`perform` でログ INSERT）
- [x] `app/services/redirect_log_service.rb` — `create_redirect_log` 追加（引数ベース、IP 判定を統合）
- [x] `app/controllers/redirects_controller.rb` — `request.remote_ip` 直接使用、`LogRedirectJob.perform_later` に変更
- [x] `bundle exec rspec spec/services/ip_address_service_spec.rb` — 通ることを確認
- [x] `bundle exec rspec spec/jobs/log_redirect_job_spec.rb` — 通ることを確認
- [x] **コミット**: `refactor: MaxMind DB をクラスレベルでキャッシュし初期化コストを削減` / `feat: リダイレクトログ記録を LogRedirectJob で非同期化`

---

## Phase B: セキュリティ修正（#4, #5）

- [x] `public/403.html` — 海外遮断ページを作成（英語表記）
- [x] `app/controllers/redirects_controller.rb` — overseas && 非検索エンジン bot && 非 SNS bot の場合に 403 を返す分岐を追加
- [x] `lib/crawler_patterns.rb` — `SNS_PATTERNS` をプレビュー bot トークンのみに絞り込む（`line`, `instagram`, `amazon`, `youtube` 等を除去、`facebookcatalog` 追加）
- [x] `bundle exec rspec spec/services/crawler_service_spec.rb` — LINE/Instagram 誤爆ケースが通ることを確認
- [x] `bundle exec rspec spec/requests/redirects_spec.rb` — 海外遮断・LINE 誤爆ケースが通ることを確認
- [ ] `http://localhost:3000` で SNS bot UA を curl でシミュレーション確認
- [x] **コミット**: `fix: SNS_PATTERNS をプレビュー bot 専用トークンに絞り込む (#5)` / `fix: 海外IPからの通常アクセスを 403 で遮断する (#4)`

---

## Phase C: データ整合（#6, #7）

- [x] マイグレーション作成: `original_url` に一意インデックス追加
- [x] `bin/rails db:migrate` を実行
- [x] `app/services/shortened_url_service.rb` — `normalize_url` メソッド追加・`RecordNotUnique` rescue 追加
- [x] `app/repositories/shortened_url_repository.rb` — `find_by_short_code` / `find_by_original_url` に `deleted_at: nil` 条件を追加
- [x] `bundle exec rspec spec/services/shortened_url_service_spec.rb` — RecordNotUnique ケースが通ることを確認
- [x] `bundle exec rspec spec/repositories/shortened_url_repository_spec.rb` — deleted_at ケースが通ることを確認
- [x] `bundle exec rspec spec/requests/api/urls_spec.rb` — ファイル未作成のためスキップ（spec/requests/redirects_spec.rb で代替確認済み）
- [x] `bundle exec rspec spec/requests/redirects_spec.rb` — deleted_at ケースが通ることを確認
- [x] **コミット**: `fix: original_url 一意制約・deleted_at フィルタ・URL 正規化を追加 (#6, #7)`

---

## Phase D: 品質（#8〜#13）

- [x] `app/views/layouts/application.html.erb` — `<html lang="ja">` に変更 (#8)
- [x] `app/frontend/components/Main/Form/index.tsx` — `aria-label` / `aria-describedby` / `role="alert"` 追加 (#9, #10)
- [x] `Dockerfile` — `ARG RUBY_VERSION=3.4.3` に変更 (#11)
- [x] `package.json` — `"typecheck": "tsc --noEmit"` を scripts に追加 (#13)
- [x] `.github/workflows/ci.yml` — `npm run typecheck` ステップを追加 (#13)
- [x] `npm run typecheck` でエラーなしを確認
- [x] `npm run build` でビルドエラーなしを確認
- [x] `bundle exec rspec spec/models/` — ディレクトリ未作成のためスキップ（対象 spec なし）
- [x] **コミット**: `fix: a11y・Ruby バージョン・フロント型検査 CI を修正 (#8-#11, #13)`

---

## 最終確認

- [x] `bundle exec rspec` で全テストが通る（110 examples, 0 failures）
- [x] `bundle exec brakeman` でセキュリティ警告なし（Security Warnings: 0）
- [x] `npm run build` でビルドエラーなし
- [x] `npm run typecheck` で型エラーなし
- [ ] `http://localhost:3000` で全体の目視確認済み
- [ ] PR 作成（base: `main`、title: `fix: コードレビュー指摘13件を修正`）
