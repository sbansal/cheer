require 'resque/server'

Rails.application.routes.draw do
  constraints subdomain: 'app' do
    devise_scope :user do
        get "/sign_up" => "accounts#new"
      end
    devise_for :users, path: '', path_names: { sign_in: 'login', sign_out: 'logout'},
      controllers: { registrations: 'registrations', sessions: 'sessions' }
    root to: 'dashboard#cashflow'
    resources :transactions, only: [:index, :show, :destroy, :edit, :update] do
      scope module: 'transactions' do
        resources :related, only: [:index]
      end
    end

    resources :categories, only: [:index, :show] do
      scope module: 'categories' do
        resources :transactions, only: [:index]
      end
    end

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
    resources :login_items, only: [:index, :destroy, :show]
    get '/login_items/:id/refresh_transactions/', to: 'login_items#refresh_transactions', as: :refresh_transactions
    get '/login_items/:id/refresh_historical_transactions', to: 'login_items#refresh_historical_transactions', as: :refresh_historical_transactions

    #events resources
    post '/events/login_item_callback', to: 'events#login_item_callback'
    post '/events/ping', to: 'events#ping'

    #bank accounts resources
    resources :bank_accounts do
      resources :balances, only: [:index, :show]
    end
    get '/bank_accounts/:id/refresh/', to: 'bank_accounts#refresh', as: :refresh_balance

    #accounts resources
    resources :companies, only: [:new, :create]
    get 'settings', to: 'companies#settings'
    get 'companies/cashflow_trend'
    get 'companies/income_expense_trend'

    #users resources
    resources :users, only: [:update]
    post '/users/invite_person'
    post '/users/:id/reinvite', to: 'users#reinvite', as: :reinvite_user
    authenticate :user, lambda {|u| u.admin? } do
      mount Resque::Server.new, :at => "/resque"
      get '/users', to: 'users#index'
    end

    #two factor authentication routes
    resources :two_factor_authentication, only: [:new, :create]
    delete '/two_factor_authentication', to:'two_factor_authentication#destroy'

    # subscriptions
    resources :subscriptions, only: [:index, :show, :update]

    #expenses
    resources :expenses, only: [:index]
    resources :earnings, only: [:index]
  end
end
