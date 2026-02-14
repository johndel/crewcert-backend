Rails.application.routes.draw do
  # Devise routes
  devise_for :users, skip: [:registrations, :sessions, :passwords, :confirmations]
  as :user do
    delete "/users/sign_out", to: "devise/sessions#destroy", as: :destroy_user_session
  end

  devise_for :super_admins, skip: [:registrations, :sessions, :passwords, :confirmations]
  as :super_admin do
    delete "/super_admins/sign_out", to: "devise/sessions#destroy", as: :destroy_super_admin_session
  end

  # Super Admin namespace
  scope path: "super_admin", as: "super_admin", module: "super_admins" do
    resources :magic_links, only: [:new, :create]
    get "magic_links/verify/:token", to: "magic_links#verify", as: :verify_magic_link
    get "admins", to: "admins#index", as: :admins
    root "home#index"
  end

  # Admin namespace (regular users)
  scope path: "admin", as: "admin", module: "admin" do
    resources :magic_links, only: [:new, :create]
    get "magic_links/verify/:token", to: "magic_links#verify", as: :verify_magic_link

    resources :vessels do
      member do
        post :request_all_certificates
        get :readiness
      end
    end
    resources :roles
    resources :certificate_types
    resources :crew_members do
      member do
        post :send_certificate_request
      end
    end
    resources :certificates do
      member do
        post :verify
        post :reject
      end
    end
    resources :matrix, only: [:index] do
      collection do
        patch :update_requirement
      end
    end

    root "home#index"
  end

  # Public certificate upload (no authentication required)
  get "upload/:token", to: "uploads#show", as: :upload
  post "upload/:token", to: "uploads#submit"
  post "upload/:token/upload_certificate", to: "uploads#upload_certificate", as: :upload_certificate

  # Root path - redirect to admin
  root "admin/home#index"

  # Health check endpoint
  get "up" => "rails/health#show", as: :rails_health_check
end
