Rails.application.routes.draw do
  devise_for :super_admins, skip: [:registrations, :sessions, :passwords, :confirmations]
  as :super_admin do
    delete "/super_admins/sign_out", to: "devise/sessions#destroy", as: :destroy_super_admin_session
  end

  scope path: "super_admin", as: "super_admin", module: "super_admins" do
    resources :magic_links, only: [:new, :create] do
      member do
        get :verify
      end
    end
    get "admins", to: "admins#index", as: :admins
    root "home#index"
  end

  # Root path - redirect to super admin
  root "super_admins/home#index"

  # Health check endpoint
  get "up" => "rails/health#show", as: :rails_health_check
end
