const REGEX_ZERO = 0;
const REGEX_MIN_LENGTH = 1;
const REGEX_MAX_LENGTH = 2048;

const PROTOCOLS = {
  HTTP: 'http:',
  HTTPS: 'https:',
};

const VALIDATE_MESSAGES = {
  REQUIRED: "URLは必須です",
  INVALID: "URLの形式が不正です",
  INVALID_PROTOCOL: "HTTPまたはHTTPSのURLを入力してください",
  INVALID_DOMAIN: "有効なドメインを含むURLを入力してください",
  TOO_LONG: "URLが長すぎます（2048文字以内で入力してください）",
};


export {
  REGEX_ZERO,
  REGEX_MIN_LENGTH,
  REGEX_MAX_LENGTH,
  PROTOCOLS,
  VALIDATE_MESSAGES,
};
