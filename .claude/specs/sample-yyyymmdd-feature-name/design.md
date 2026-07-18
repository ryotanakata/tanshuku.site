# Design

<!--
雛形の使い方:
要件（requirement.md）が固まったあと、実装方針を記述する。
-->

## 1. アーキテクチャ概要

<!--
変更の全体像を1〜2段落で説明する。
どの層に何を追加・変更するかを明示する。
-->

## 2. ディレクトリ構成（差分）

```
app/
├── controllers/
│   └── api/                  ← API エンドポイント
├── services/                 ← ビジネスロジック
├── repositories/             ← データアクセス
├── validators/               ← バリデーション
├── models/                   ← Active Record エンティティ
└── frontend/
    ├── components/           ← React コンポーネント
    ├── hooks/                ← カスタムフック
    ├── schemas/              ← Zod スキーマ
    ├── constants/            ← 定数
    └── styles/               ← SCSS
```

## 3. 実装詳細

### 3-1. バックエンド層

<!--
Controller / Service / Repository / Validator の設計を記述する。
クラス構造・メソッド責務・DI パターンを明示する。
-->

**レイヤー構成**:

```
Controller（params 抽出・Validator 委譲・Service 委譲）
  → Validator（入力値バリデーション・例外送出）
  → Service（ビジネスロジック）
    → Repository（Active Record CRUD）
      → Model（DB スキーマ）
```

### 3-2. フロントエンド設計

<!--
コンポーネント構造・カスタムフック・Zod スキーマ・API 呼び出しを記述する。
-->

### 3-3. Vite / SCSS

<!--
CSS エントリ・CSS Modules・prod/dev 両対応を確認する。
-->

## 4. データフロー

```
React コンポーネント
  → POST /api/{endpoint} （X-CSRF-TOKEN ヘッダー付き）
    → Api::{Name}Controller
      → {Name}Validator#validate_creation!
      → {Name}Service#{method}
        → {Name}Repository#{crud_method}
  → JSON レスポンス → React 状態更新
```

## 5. リスクと対策

| リスク | 対策 |
|---|---|
| DB マイグレーション失敗 | `bin/rails db:rollback` でロールバック |
| Vite HMR が効かない | `bin/vite dev` を再起動 |
| Brakeman 警告 | 指摘を確認し修正してからマージ |
| ... | ... |

## 6. 移行フェーズ（複数フェーズに分ける場合）

| Phase | 内容 | 状態 |
|---|---|---|
| A | ... | 未着手 |
| B | ... | 未着手 |
