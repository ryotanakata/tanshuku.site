Rails.application.routes.draw do
  root "pages#index"

  # API routes for URL shortening
  namespace :api do
    get 'urls/test', to: 'urls#test'
    resources :urls, only: [:create]
  end

  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # ========================================
  # Short URL Redirect Routes
  # ========================================
  # This route handles redirecting short URLs (e.g., /s/ABC123) to their original URLs
  # The route must be placed last to avoid conflicts with other routes
  #
  # Example usage:
  # - User visits: /s/ABC123
  # - RedirectsController#show is called with short_code: "ABC123"
  # - User is redirected to the original URL
  get 's/:short_code', to: 'redirects#show', as: :short_url
  get 's/:short_code/', to: 'redirects#show', as: :short_url_with_slash
end
