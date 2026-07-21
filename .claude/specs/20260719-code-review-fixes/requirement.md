# Requirements

## 目的

コードレビューで指摘された13件（critical 1・high 1・medium 11）の問題を修正し、
本番の安定性・セキュリティ・保守性を向上させる。

## 現状

| # | 重要度 | 問題 |
|---|---|---|
| 1 | CRITICAL | リダイレスト毎に MaxMind DB（約81MB）をメモリ全読み込み → OOM / 高レイテンシ |
| 2 | MEDIUM | アクセスログ書き込みがホットパスで同期実行 → リダイレクトが直列化 |
| 3 | MEDIUM | IP判定に偽装可能な XFF 先頭値を使用、ログと判定元IPが不整合 |
| 4 | MEDIUM | README は「海外遮断」と謳うが未実装（海外からも通過） |
| 5 | MEDIUM | SNS クローラー判定の部分一致が広く LINE/Instagram 等の実ユーザーを誤爆 |
| 6 | MEDIUM | original_url に一意制約なし、並行リクエストで重複行が発生 |
| 7 | MEDIUM | deleted_at 列があるが Repository がフィルタしないためテイクダウン不能 |
| 8 | MEDIUM | メインレイアウトに `lang` 属性なし（WCAG 3.1.1） |
| 9 | MEDIUM | URL 入力フィールドにラベルなし（WCAG 4.1.2） |
| 10 | MEDIUM | エラー文が入力とプログラム的に未紐付け（WCAG 3.3.1） |
| 11 | MEDIUM | Dockerfile の Ruby バージョンが .ruby-version / CI と不一致（3.3.0 vs 3.4.3） |
| 12 | MEDIUM | RedirectsController の request/model spec が皆無 |
| 13 | MEDIUM | CI にフロントエンドの型検査ステップがない |

## スコープ

| 区分 | 含む | 含まない |
|---|---|---|
| バックエンド | IpAddressService メモ化・LogRedirectJob 新設・overseas 遮断・crawler 判定修正・RecordNotUnique rescue・deleted_at フィルタ | rack-attack MemoryStore 移行・CSP 設定・paranoia gem 有効化 |
| フロントエンド | lang属性・aria-label・aria-describedby | useDialog 修正・axios timeout・エラーメッセージ表示改善 |
| ビルド/CI | Dockerfile Ruby バージョン・npm run typecheck 追加 | Node バージョン統一・npm audit レベル変更 |
| テスト | request spec / model spec / job spec 追加 | system spec・E2E テスト |

### あえてやらないこと

- `paranoia` gem の `acts_as_paranoid` 有効化（管理 UI なしでは cascade との整合が複雑）
- `useDialog` のアニメーション修正（別 PR で対応）
- `build_url` の冗長クエリ最適化（影響範囲が広く単独 PR 推奨）

## 前提・依存

- Docker Compose が起動していること（PostgreSQL: `localhost:5432`）
- Rails サーバが起動していること（`http://localhost:3000`）
- `lib/maxmind/*.mmdb` ファイルが存在すること（IpAddressService が参照）
- solid_queue ワーカーが起動していること（非同期ログのため）

## 完了条件

- [ ] `bundle exec rspec` で全テストが通る
- [ ] `bundle exec brakeman` でセキュリティ警告なし
- [ ] `npm run build` でビルドエラーなし
- [ ] `npm run typecheck` で型エラーなし
- [ ] リダイレクト時に MaxMind::DB.new がプロセスあたり3回以内しか呼ばれない（メモ化確認）
- [ ] 海外 IP（US等）からのアクセスが 403 を返す（`curl` で確認）
- [ ] LINE アプリ内 UA が OGP ページでなく 302 を返す
- [ ] `http://localhost:3000` で目視確認済み

## 非機能要件

- リダイレクトの p99 レイテンシが修正前と同等以上に改善
- アクセシビリティ: WCAG 2.1 AA（lang・label・aria-describedby）
