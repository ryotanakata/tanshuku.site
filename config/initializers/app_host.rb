Rails.application.configure do
  # ホスト
  host = ENV.fetch("APP_HOST") { "http://localhost:3000" }

  # デフォルトのホスト
  Rails.application.routes.default_url_options[:host] = host

  # メールのURL生成
  config.action_mailer.default_url_options = { host: host }

  # CDN
  config.action_controller.asset_host = ENV["ASSET_HOST"] if ENV["ASSET_HOST"]

  # ベースURL
  config.base_url = host
end
