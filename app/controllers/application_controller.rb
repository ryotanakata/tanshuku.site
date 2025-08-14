class ApplicationController < ActionController::Base
  # CSRF保護を有効にする
  protect_from_forgery with: :exception
end
