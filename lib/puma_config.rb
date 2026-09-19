# Puma 設定(config/puma.rb)の判定ロジック。
# config/puma.rb は Rails のオートロード対象外のため、判定ロジックを独立したファイルに
# 切り出すことでテスト可能にする(config/puma.rb 自体は spec でロードできないため)。

module PumaConfig
  # Solid Queue supervisor を Puma プロセス内で起動するかどうかを判定する。
  #
  # Railway は web と job worker を同一プロセスで兼ねる単一サービス構成のため、
  # SOLID_QUEUE_IN_PUMA が未設定の場合は production でのみデフォルトで有効にする。
  # (config/deploy.yml の Kamal 用設定はこのデプロイ経路では使われないため、
  # そちらに書かれた SOLID_QUEUE_IN_PUMA は Railway 環境には反映されない)
  #
  # @param env [Hash] 環境変数(ENV 互換のオブジェクト)
  # @return [Boolean] Solid Queue supervisor を Puma 内で起動する場合は true
  def self.solid_queue_in_puma?(env)
    env.key?("SOLID_QUEUE_IN_PUMA") ? env["SOLID_QUEUE_IN_PUMA"] == "true" : env["RAILS_ENV"] == "production"
  end
end
