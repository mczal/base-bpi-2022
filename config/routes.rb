require 'sidekiq/web'
require 'sidekiq-scheduler/web'

Rails.application.routes.draw do
  get 'home', to: "homes#index"
  get 'err_page', to: "homes#err_page"

  get 'register_sia', to: "authentication_users#register_sia"
  get 'login_sia', to: "authentication_users#login_sia"

  constraints Clearance::Constraints::SignedIn.new do
    mount Sidekiq::Web, at: '/sidekiq'
    root to: "homes#index", as: :signed_in_root
  end

  constraints Clearance::Constraints::SignedOut.new do
    root to: "homes#index"
  end

  namespace :admin, path: ":slug" do
    resources :users
    resources :general_transactions

    resources :accounts
    namespace :accounts do
      get "actions/download_template",
        to: "actions#download_template",
        as: :download_template
      post 'actions/import',
          to: 'actions#import',
          as: :action_import
    end

    resources :master_business_units, only: %i[index show update destroy create]
    post 'master_business_units/:id/edit',
      to: 'master_business_units#edit',
      as: :edit_master_business_unit

    resources :journals
    namespace :journals do
      post 'actions/export',
          to: 'actions#export',
          as: :action_export

      post 'actions/import',
          to: 'actions#import',
          as: :action_import

      get "actions/download_template",
          to: "actions#download_template",
          as: :download_template
    end

    resources :reports
    namespace :reports do
      get "actions/download_template",
        to: "actions#download_template",
        as: :download_template

      post 'actions/export_pdf',
          to: 'actions#export_pdf',
          as: :action_export_pdf

      post 'actions/export',
          to: 'actions#export',
          as: :action_export

      post 'actions/import',
          to: 'actions#import',
          as: :action_import

      get "actions/import",
          to: "actions#import_form",
          as: :import

      get "actions/import_preview",
          to: "actions#import_preview",
          as: :import_preview
    end

    resources :companies
    resources :settings, only: [:index]
    namespace :settings do
      resources :company_profiles, only: [:index, :create]
      resources :closed_journals, only: [:index, :create, :destroy]
      resources :general_importers, only: %i[index create]
    end
  end

  namespace :api do
    namespace :v1 do
      namespace :accountings do
        post "authentication", to: "authentications#get_account", as: :authentication
        post "create_user", to: "authentications#create_user", as: :create_user
        post "signed_in_user", to: "authentications#signed_in_user", as: :signed_in_user
      end
    end

    namespace :admin do
      namespace :general_transactions do
        post 'get-all', to: 'index#show', as: :index
      end
      namespace :users do
        post 'get-all', to: 'index#show', as: :index
      end
      namespace :accounts do
        post 'get-all', to: 'index#show', as: :index
      end
      namespace :master_business_units do
        post 'get-all', to: 'index#show', as: :index
      end
      namespace :companies do
        post 'get-all', to: 'index#show', as: :index
      end
    end
  end
end
