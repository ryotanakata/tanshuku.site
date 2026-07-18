# フロントエンド規約（tanshuku）

## Vite / ビルド

- エントリポイント: `app/frontend/entrypoints/application.tsx`
- グローバル CSS エントリ: `app/frontend/styles/style.scss`
- ビルド出力: `public/vite-dev/`（開発）/ `public/vite/`（本番）
- dev サーバ: `bin/vite dev`（`http://localhost:3036`、HMR あり）
- 本番ビルド: `npm run build`

エイリアス:

| エイリアス | 解決先                    |
| ---------- | ------------------------- |
| `@`        | `app/frontend/`           |

CSS Modules の設定（`vite.config.ts`）:

- `localsConvention: "camelCase"` — クラス名は camelCase でアクセス
- `generateScopedName: "style_[local]__[hash:base64:5]"` — スコープ付きクラス名

## React（TypeScript）

`app/frontend/` 以下が React + TypeScript のソース。単一エントリポイント（SPA）。

### ディレクトリ構成

```
app/frontend/
├── entrypoints/
│   └── application.tsx        # エントリポイント（#root に React をマウント）
├── pages/
│   └── {ページ名}/
│       └── page.tsx           # ページコンポーネント（default export）
├── components/
│   └── ComponentName/
│       ├── index.tsx          # JSX のみ（ロジックは hooks.ts に逃がす）
│       ├── hooks.ts           # そのコンポーネント専用のローカルフック
│       ├── style.module.scss  # CSS Modules
│       └── {SubComponent}/   # 同一コンポーネント内に閉じたサブコンポーネント
├── hooks/
│   └── use{Name}.ts           # 複数コンポーネントで再利用するグローバルフック
├── schemas/
│   └── {名前}Schema.ts        # Zod スキーマ
├── constants/
│   └── {名前}Constant.ts      # 定数（バリデーションメッセージ・エンドポイント等）
├── types/
│   ├── scss.d.ts              # CSS Modules 型定義
│   └── {名前}Type.ts          # 機能別型定義
├── utils/
│   ├── internalApi.ts         # Rails API クライアント（axios）
│   ├── externalApi.ts         # 外部 API クライアント
│   └── {名前}.ts              # 汎用ユーティリティ
└── styles/
    ├── style.scss             # グローバルスタイルエントリ
    ├── Foundation/            # reset / base / variable / mixin / utility
    └── Object/                # 再利用コンポーネントスタイル
```

### コンポーネント規約

- `index.tsx` は JSX のみ。state・副作用・イベントハンドラはローカルフック（`hooks.ts`）に逃がす
- **named export のみ**（`default export` は pages/ のページコンポーネントのみ許可）
- `index.tsx` が肥大化する場合は同フォルダ内にサブコンポーネントとして分割する

```tsx
// components/Main/Form/index.tsx
const Form = () => {
  const { register, onSubmit, errors } = useFormHooks();
  return <form onSubmit={onSubmit}> ... </form>;
};

export { Form };
```

### ローカルフック vs グローバルフック

フックの置き場所は「再利用するかどうか」で決める。

| 種類 | 置き場所 | 命名 | 用途 |
|---|---|---|---|
| **ローカルフック** | `ComponentName/hooks.ts` | `use{ComponentName}Hooks` | そのコンポーネントにしか使わない state・副作用・イベント |
| **グローバルフック** | `hooks/use{Name}.ts` | `use{Name}` | 複数コンポーネントで共有するロジック（例: `useDialog`） |

**ローカルフックの規約**:
- 1 ファイルにつき 1 つの `use{ComponentName}Hooks()` 関数を export する
- **引数なし・オブジェクト返し**を基本とする
- props が必要な場合は引数で受け取る

```typescript
// components/Main/Form/hooks.ts — ローカルフック
const useFormHooks = () => {
  const { register, handleSubmit, formState: { errors } } = useForm({
    resolver: zodResolver(urlSchema),
  });

  const onSubmit = handleSubmit(async (data) => { /* ... */ });

  return { register, onSubmit, errors };
};

export { useFormHooks };
```

**グローバルフックの規約**（`hooks/` ディレクトリ）:
- 複数のコンポーネントから呼ばれることが確定しているときのみ `hooks/` に置く
- ファイル名は `use` プレフィックス + camelCase（例: `useDialog.ts`）
- JSDoc を必須とする

```typescript
// hooks/useDialog.ts — グローバルフック
/**
 * dialog タグの開閉を制御するカスタムフック
 * @param options
 */
const useDialog = (options: { overlayColor?: string } = {}) => {
  /* ... */
  return { dialogRef, openDialog, closeDialog };
};

export { useDialog };
```

### TypeScript 規約

- `any` 禁止 → `unknown` + 型絞り込みを使う
- `null` / `undefined` は必ず明示チェック（`strict: true` 有効）
- 型定義は `app/frontend/types/{名前}Type.ts`
- コンポーネントの props 型はインラインで定義する（`type Props = ...` は作らない）

```typescript
// OK: インライン
const Item = ({ label }: { label: string }) => <span>{label}</span>;

// NG: Props 型を別に定義
type Props = { label: string };
const Item = ({ label }: Props) => <span>{label}</span>;
```

### Zod スキーマ（`schemas/` に分離）

スキーマは `app/frontend/schemas/{名前}Schema.ts` に切り出す。定数（正規表現・バリデーションメッセージ）は `constants/` に置いてスキーマから import する。

```typescript
// schemas/urlSchema.ts
import { z } from "zod";
import { VALIDATE_MESSAGES, REGEX_MAX_LENGTH } from "@/constants/urlConstant";

const urlSchema = z.object({
  url: z
    .string()
    .min(1, VALIDATE_MESSAGES.REQUIRED)
    .max(REGEX_MAX_LENGTH, VALIDATE_MESSAGES.TOO_LONG)
    .refine((url) => { /* URL 検証 */ }, VALIDATE_MESSAGES.INVALID),
});

export { urlSchema };
```

### React Hook Form + Zod

`zodResolver` でスキーマを接続する。各フィールドは `register` または `Controller` で管理する。

```typescript
// hooks/useUrlFormHooks.ts
import { useForm } from "react-hook-form";
import { zodResolver } from "@hookform/resolvers/zod";
import { urlSchema } from "@/schemas/urlSchema";

const useUrlFormHooks = () => {
  const { register, handleSubmit, formState: { errors } } = useForm({
    resolver: zodResolver(urlSchema),
    mode: "onChange",
  });

  const onSubmit = handleSubmit(async (data) => {
    await fetchShortenedUrl(data.url);
  });

  return { register, onSubmit, errors };
};

export { useUrlFormHooks };
```

### API クライアント

内部 API（Rails）は `app/frontend/utils/internalApi.ts` の axios インスタンスを使う。CSRF トークンはインターセプターで自動付与されるため、呼び出し元では意識しない。

```typescript
// utils/internalApi.ts（既存ファイル）
const apiClient = axios.create({ baseURL: "/api/" });

// インターセプターで X-CSRF-TOKEN を自動付与
apiClient.interceptors.request.use((config) => {
  const token = document.querySelector<HTMLMetaElement>('meta[name="csrf-token"]')?.content;
  if (token) config.headers["X-CSRF-TOKEN"] = token;
  return config;
});
```

外部 API は `app/frontend/utils/externalApi.ts` に分ける。

エンドポイント文字列は `app/frontend/constants/` に集約し、直書き禁止。

### CSS Modules + SCSS

コンポーネントのスタイルは `style.module.scss` を作成して CSS Modules で管理する。先頭で `@use "@/styles/Foundation" as *;` をインポートする。

```scss
// components/Main/Form/style.module.scss
@use "@/styles/Foundation" as *;

.form {
  padding-block-start: 7.5%;

  .input {
    input {
      border: 2px solid var(--t-color-primary-default);
      &[aria-invalid="true"] {
        border-color: var(--t-color-red-default);
      }
    }
    @include media-size() { /* ... */ }
  }
}
```

CSS Modules のクラスは camelCase でアクセスする（`styles.formField` など）。

## Sass / SCSS

- ファイルはパーシャル（`_*.scss`）として作成し、`_index.scss` で `@forward` する
- `@import` は使わない（`@use` / `@forward` を使う）
- CSS カスタムプロパティ（`var(--t-color-*)`）をカラーに使う

### ディレクトリ構成

```
app/frontend/styles/
├── style.scss            # グローバルエントリ（Foundation と Object を @use）
├── Foundation/
│   ├── _index.scss       # @forward で各パーシャルを束ねる
│   ├── _reset.scss       # CSS リセット
│   ├── _base.scss        # ベーススタイル
│   ├── Variable/         # CSS カスタムプロパティ・SCSS 変数
│   │   ├── _breakpoint.scss
│   │   ├── _color.scss
│   │   ├── _easing.scss
│   │   ├── _path.scss
│   │   └── _size.scss
│   ├── Mixin/            # mixin 定義
│   │   ├── _hover.scss
│   │   ├── _media-size.scss
│   │   ├── _media-width.scss
│   │   ├── _visually-hidden.scss
│   │   ├── _bg-img-path.scss
│   │   └── _pseudo-element.scss
│   └── Utility/          # ユーティリティクラス
└── Object/               # ページ外で再利用されるスタイル
```

## SCSS 命名規則

### BEM 派生（`__` エレメントを原則使わない）

BEM をベースとしつつ、**ブロック内の要素はタグセレクタで指定する**独自ルール。

- ブロック単位（コンポーネント・セクション）までクラスを付ける
- ブロック内の要素はタグセレクタや直接子セレクタ（`>`）で指定
- 意味のない `<div>` にはクラスを振らない

```scss
// CSS Modules 内
.form {
  .input {
    > label { /* ... */ }
    > input { /* ... */ }
  }
}
```

### ローカル変数は連番方式

SCSS のローカル変数は連番で機械的に命名する。

```scss
.pg-column {
  $_color01: var(--t-color-primary-default);
  $_color02: var(--t-color-secondary-default);
  $_size01: 16px;
}
```

## SCSS の mixin

`app/frontend/styles/Foundation/Mixin/` に共通 mixin が定義されている。

### メディアクエリ

| mixin                        | 引数                 | 用途                           |
| ---------------------------- | -------------------- | ------------------------------ |
| `@include media-width($px)`  | 単位なしの px 数値   | 任意の値でブレークポイント発火 |
| `@include media-size($key?)` | 定義済みキー（省略可）| 既定ブレークポイントで発火    |

引数なしの `@include media-size()` はデフォルトのブレークポイント（`min-width: 768px`）で発火する。

### ホバー

`@include hover` で `:hover` + `:focus-visible` を同時に適用する。`:hover` 単体は使わない。

### a11y

`@include visually-hidden()` でスクリーンリーダー向けに視覚的に非表示にする。

### 背景画像

```scss
$_image-dir: "pages/top/";
@include bg-img-path($_image-dir, "mv-background--20260101.webp");
```

## 画像

### ファイル命名規則

`{セクション名}_{名前}_{連番}--{日付}.{拡張子}` の形式で命名する。

例: `mv-background_01--20260101.webp`

- 写真・複雑な画像: `.webp`（JPG / PNG は使わない）
- ロゴ・アイコン: `.svg`
- 必ず 2 倍解像度（Retina 対応）

## アクセシビリティ

WCAG 2.1 の **レベル AA を目標**。

- `aria-invalid="true"` でフォームエラー状態を示す
- 操作要素は `<button>`、遷移は `<a>` で使い分ける
- `@include hover` で `:focus-visible` もカバーする
- 装飾画像は `alt="" aria-hidden="true"`
- `width` / `height` 属性を指定して CLS を防ぐ

## ファイル・ディレクトリ命名規則

### ファイル名のサフィックス・プレフィックス

| ディレクトリ       | 規則                          | 例                                            |
| ------------------ | ----------------------------- | --------------------------------------------- |
| `hooks/`（グローバル）| `use` プレフィックス        | `useDialog.ts`（複数コンポーネントで共有するもの） |
| `{Component}/hooks.ts`（ローカル）| `use{ComponentName}Hooks` に固定 | `Form/hooks.ts` → `useFormHooks` |
| `schemas/`         | `Schema` サフィックス         | `urlSchema.ts`                                |
| `constants/`       | `Constant` サフィックス       | `urlConstant.ts`, `internalApiEndpoints.ts`   |
| `types/`           | `Type` サフィックス           | `urlType.ts`（`scss.d.ts` は例外）            |
| `utils/`           | サフィックスなし（機能名のみ）| `internalApi.ts`, `toggleScrollLock.ts`       |
| `components/{Name}/`| UpperCamelCase ディレクトリ、ファイル名は固定 | `Form/index.tsx`, `Form/style.module.scss` |
| `pages/{name}/`    | ファイル名は固定 `page.tsx`   | `top/page.tsx`                                |
| `entrypoints/`     | Rails 規約に従う              | `application.tsx`                             |

### コンポーネントのエクスポート

- **named export のみ**（`export { Form }` の形式）
- `pages/` の ページコンポーネントのみ **default export** を許可（React Router 等の遅延ロードに対応するため）

```tsx
// components/Main/Form/index.tsx — named export
const Form = () => { ... };
export { Form };

// pages/top/page.tsx — default export のみ許可
export default function TopPage() { ... }
```

## コーディングスタイル

| 項目         | ルール                                                  |
| ------------ | ------------------------------------------------------- |
| インデント   | 2 スペース（TypeScript / TSX / SCSS 共通）              |
| 変数         | camelCase                                               |
| 関数         | アロー関数                                              |
| エクスポート | 名前付きエクスポート（pages/ のページコンポーネントのみ default export 可） |
