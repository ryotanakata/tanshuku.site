---
name: sample
description: スキルの雛形。新しいスキルを追加するときはこのファイルをコピーして `skills/<スキル名>/SKILL.md` に配置する。`name` と `description` を書き換えること。
allowed-tools: Read, Bash, Glob, Grep
---

# スキルのタイトル

このスキルが何をするかを1〜2文で説明する。発火するキーワード例も書いておくと再利用しやすい。

## 前提

- このスキルが前提とする状態・条件を箇条書きで記述する
- 例: 「Docker が起動していること（`docker-compose up -d`）」
- 例: 「Rails サーバが起動していること（`bin/dev`）」

## 作業手順

1. **最初にやること** — 目的を一言で添える
2. **次にやること** — 目的を一言で添える
3. **最後にやること** — 完了確認方法も書く

## ファイル・ディレクトリ規約

| 対象 | 場所 | 備考 |
|---|---|---|
| Service | `app/services/{name}_service.rb` | DI パターン必須 |
| Repository | `app/repositories/{name}_repository.rb` | Active Record CRUD のみ |
| Validator | `app/validators/{name}_validator.rb` | 例外送出で失敗を通知 |
| Controller | `app/controllers/api/{name}s_controller.rb` | 薄い Controller |
| React コンポーネント | `app/frontend/components/{Name}/index.tsx` | JSX のみ |
| カスタムフック | `app/frontend/hooks/use{Name}.ts` | ロジックを集約 |
| Zod スキーマ | `app/frontend/schemas/{name}Schema.ts` | 定数は constants/ から import |

## 規約

- Controller → Service → Repository の一方向依存のみ（Controller が Repository を直接呼ばない）
- Service と Repository はコンストラクタ DI を使う
- named export のみ（pages/ のページコンポーネントのみ default export 可）
- 例: 「フロントエンドの CSRF トークンは `internalApi.ts` のインターセプターが付与する」

## 注意

- 新しい API エンドポイントを追加したら rack-attack の設定も確認する
- Brakeman の警告が出た場合は必ず修正してからマージする
- DB マイグレーションが必要な場合は `bin/rails db:rollback` で戻せることを確認してから適用する

## 完了チェックリスト

- [ ] ファイルが正しいディレクトリに作成されている
- [ ] Controller → Service → Repository の依存方向が正しい
- [ ] `bundle exec rspec` でテストが通る
- [ ] `bundle exec brakeman` でセキュリティ警告なし
- [ ] `npm run build` でビルドエラーなし
- [ ] `http://localhost:3000` で動作確認した
