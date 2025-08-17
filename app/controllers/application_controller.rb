class ApplicationController < ActionController::Base
  # CSRF保護を有効にする
  protect_from_forgery with: :exception

  # HTMLファイルのキャッシュ制御
  before_action :set_html_cache_headers

  private

  def set_html_cache_headers
    if Rails.env.production?
      # HTMLは毎回更新を取りに行かせる
      response.headers["Cache-Control"] = "no-store, must-revalidate"
      response.headers["Pragma"] = "no-cache"
      response.headers["Expires"] = "0"
    end
  end
end
