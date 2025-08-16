const REGEX_ZERO = 0;
const REGEX_MIN_LENGTH = 1;
const REGEX_MAX_LENGTH = 2048;
const REGEX_HOST =
  /^(?!\d+\.\d+\.\d+\.\d+$)[a-zA-Z0-9]([a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(\.[a-zA-Z0-9]([a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)+$/;

const PROTOCOLS = {
  HTTP: "http:",
  HTTPS: "https:",
};

const VALIDATE_MESSAGES = {
  REQUIRED: "URLを入力してください",
  INVALID: "URLの形式が不正です",
  INVALID_PROTOCOL: "http://またはhttps://から始まるURLを入力してください",
  INVALID_DOMAIN: "有効なドメインを含むURLを入力してください",
  TOO_LONG: "URLが長すぎます（2048文字以内で入力してください）",
};

export {
  REGEX_ZERO,
  REGEX_MIN_LENGTH,
  REGEX_MAX_LENGTH,
  REGEX_HOST,
  PROTOCOLS,
  VALIDATE_MESSAGES,
};
