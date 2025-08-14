# クローラーパターンの定義
# 検索エンジンや生成AIのbotを識別するためのパターン

module CrawlerPatterns
  PATTERNS = {
    google: [
      'googlebot',
      'googlebot-image',
      'googlebot-news',
      'googlebot-video',
      'apis-google',
      'adsbot-google',
      'mediapartners-google'
    ],
    bing: [
      'bingbot',
      'msnbot',
      'adidxbot'
    ],
    yandex: [
      'yandexbot',
      'yandexmetrika'
    ],
    baidu: [
      'baiduspider',
      'baiduspider-image'
    ],
    facebook: [
      'facebookexternalhit',
      'facebookcatalog'
    ],
    twitter: [
      'twitterbot'
    ],
    linkedin: [
      'linkedinbot'
    ],
    slack: [
      'slackbot'
    ],
    openai: [
      'openai-ip',
      'openai-bot',
      'gptbot'
    ],
    anthropic: [
      'anthropic-ai',
      'claude-bot',
      'anthropicbot'
    ],
    google_ai: [
      'google-ai',
      'gemini-bot',
      'palm-bot'
    ],
    microsoft_ai: [
      'ms-ai',
      'copilot-bot',
      'bing-ai'
    ],
    meta_ai: [
      'meta-ai',
      'llama-bot',
      'meta-llama'
    ],
    cohere: [
      'cohere-bot',
      'cohere-ai'
    ],
    huggingface: [
      'huggingface-bot',
      'hf-bot'
    ],
    research: [
      'research-bot',
      'academic-bot',
      'university-bot'
    ]
  }.freeze
end
