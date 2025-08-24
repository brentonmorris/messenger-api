require "sidekiq/web"

Rails.application.routes.draw do
  scope "/api" do
    devise_for :users, defaults: {format: :json}, path: "", path_names: {
                                                              sign_in: "login",
                                                              sign_out: "logout"
                                                            },
      controllers: {
        sessions: "api/users/sessions"
      },
      skip: [:registrations]

    post "twilio/message-status-callback", to: "api/twilio/webhooks#message_status_callback"

    resources :messages, controller: "api/messages"

    get "me", to: "api/base#get_current_user"
  end

  # Mount Sidekiq web interface with basic auth in production
  if Rails.env.production?
    Sidekiq::Web.use Rack::Auth::Basic do |username, password|
      ActiveSupport::SecurityUtils.secure_compare(::Digest::SHA256.hexdigest(username), ::Digest::SHA256.hexdigest(ENV.fetch("SIDEKIQ_USERNAME", "admin"))) &&
        ActiveSupport::SecurityUtils.secure_compare(::Digest::SHA256.hexdigest(password), ::Digest::SHA256.hexdigest(ENV.fetch("SIDEKIQ_PASSWORD", "password")))
    end
  end

  mount Sidekiq::Web => "/sidekiq"

  get "up" => "rails/health#show", :as => :rails_health_check

  root to: "rails/health#show"
end
