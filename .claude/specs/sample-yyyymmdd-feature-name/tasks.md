# Tasks

<!--
雛形の使い方:
design.md の方針に従ってタスクを分解する。
完了したタスクは `- [x]` にチェックを入れる。
-->

## 進め方

[design.md](design.md) に従い **Phase A → B → ...** で進める。
各タスク完了で `[x]`。目視確認は `http://localhost:3000` で行う。

---

## Phase 0: 事前確認

- [ ] Docker が起動していることを確認（`docker-compose up -d`）
- [ ] Rails サーバが起動していることを確認（`bin/dev`）
- [ ] 現状の動作を確認・記録（比較用）
- [ ] `bundle exec rspec` で既存テストが全て通ることを確認

---

## Phase A: （フェーズ名）

- [ ] DB マイグレーション作成（必要な場合）
- [ ] Model の追加・変更
- [ ] Repository の追加・変更
- [ ] Validator の追加・変更
- [ ] Service の追加・変更
- [ ] Controller の追加・変更
- [ ] ルーティング設定（`config/routes.rb`）
- [ ] **コミット**: `add: （機能名）のバックエンド実装`

---

## Phase B: フロントエンド実装

- [ ] Zod スキーマ作成（`app/frontend/schemas/`）
- [ ] 定数追加（`app/frontend/constants/`）
- [ ] コンポーネント作成（`app/frontend/components/`）
- [ ] カスタムフック作成（`app/frontend/hooks/`）
- [ ] SCSS 作成（`style.module.scss`）
- [ ] `npm run build` でビルドエラーなし
- [ ] `http://localhost:3000` で目視確認
- [ ] **コミット**: `add: （機能名）のフロントエンド実装`

---

## Phase C: テスト・品質確認

- [ ] `bundle exec rspec spec/services/` でサービステスト
- [ ] `bundle exec rspec spec/repositories/` でリポジトリテスト
- [ ] `bundle exec rspec spec/requests/` でリクエストテスト
- [ ] `bundle exec brakeman` でセキュリティ警告なし
- [ ] **コミット**: `add: （機能名）のテスト追加`

---

## 完了条件（requirement.md より）

- [ ] ...
- [ ] `bundle exec rspec` でテストが全て通る
- [ ] `bundle exec brakeman` でセキュリティ警告なし
- [ ] `npm run build` でビルドエラーなし
- [ ] `http://localhost:3000` で動作・表示確認済み
