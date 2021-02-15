require 'resque/server'

Rails.application.routes.draw do
  constraints subdomain: 'app' do
    devise_scope :user do
        get "/sign_up" => "accounts#new"
      end
    devise_for :users, path: '', path_names: { sign_in: 'login', sign_out: 'logout'},
      controllers: { registrations: 'registrations', sessions: 'sessions' }
    root to: 'dashboard#cashflow'
    resources :transactions, only: [:index, :show, :destroy, :edit, :update]
    get '/transactions/:id/related', to: 'transactions#related', as: :related_transactions

    resources :categories, only: [:index, :show]

    resources :subscriptions, only: [:index, :destroy]
    # search resources
    get '/search/address', to: 'search#address'
    get '/search/institution', to: 'search#institution'

    #dashboard resources
    get '/cashflow', to: 'dashboard#cashflow'
    get '/income_expense', to: 'dashboard#income_expense', as: :income_expense

    #plaid resources
    post '/plaid/generate_access_token', to: 'plaid#generate_access_token'
    post '/plaid/update_link', to: 'plaid#update_link'
    post '/plaid/create_link_token', to: 'plaid#create_link_token'

    #login items resources
    resources :login_items, only: [:index, :destroy]
    get '/login_items/:id/refresh_transactions/', to: 'login_items#refresh_transactions', as: :refresh_transactions
    get '/login_items/:id/refresh_historical_transactions', to: 'login_items#refresh_historical_transactions', as: :refresh_historical_transactions
    get '/login_items/:id/status', to: 'login_items#status'

    #events resources
    post '/events/login_item_callback', to: 'events#login_item_callback'

    #bank accounts resources
    resources :bank_accounts do
      resources :balances, only: [:index]
    end
    get '/bank_accounts/:id/refresh/', to: 'bank_accounts#refresh', as: :refresh_balance

    #accounts resources
    resources :accounts, only: [:new, :create]
    get 'accounts/settings'
    get 'accounts/cashflow_trend'

    #users resources
    resources :users, only: [:update]
    post '/users/invite_person'
    post '/users/:id/reinvite', to: 'users#reinvite', as: :reinvite_user
    authenticate :user, lambda {|u| u.admin? } do
      mount Resque::Server.new, :at => "/resque"
    end

    #two factor authentication routes
    resources :two_factor_authentication, only: [:new, :create]
    delete '/two_factor_authentication', to:'two_factor_authentication#destroy'
  end
end
