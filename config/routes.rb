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
    resources :magic_links, only: [:new, :create] do
      member do
        get :verify
      end
    end
    get "admins", to: "admins#index", as: :admins
    root "home#index"
  end

  # Admin namespace (regular users)
  scope path: "admin", as: "admin", module: "admin" do
    resources :magic_links, only: [:new, :create] do
      member do
        get :verify
      end
    end
    root "home#index"
  end

  # Root path - redirect to admin
  root "admin/home#index"

  # Health check endpoint
  get "up" => "rails/health#show", as: :rails_health_check
end
