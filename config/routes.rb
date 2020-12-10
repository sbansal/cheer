require 'resque/server'

Rails.application.routes.draw do
  constraints subdomain: 'app' do
    devise_for :users, path: '', path_names: { sign_in: 'login', sign_out: 'logout'}
    root to: 'dashboard#income_expense'
    resources :transactions, only: [:index, :show, :destroy]

    resources :categories, only: [:index]

    resources :subscriptions, only: [:index, :destroy]
    # search resources
    get '/search/address', to: 'search#address'
    get '/search/institution', to: 'search#institution'

    #dashboard resources
    get '/dashboard/home', to: 'dashboard#home'
    get '/cashflow', to: 'dashboard#cashflow'
    get '/income_expense', to: 'dashboard#income_expense', as: :income_expense
    get '/dashboard/transactions', to: 'dashboard#transactions'

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
    resources :bank_accounts
    get '/bank_accounts/:id/refresh/', to: 'bank_accounts#refresh', as: :refresh_balance

    #accounts resources
    get 'accounts/settings'
    get 'accounts/cashflow_trend'

    #users resources
    post '/users/invite_person'
    post '/users/:id/reinvite', to: 'users#reinvite', as: :reinvite_user
    authenticate :user, lambda {|u| u.admin? } do
      mount Resque::Server.new, :at => "/resque"
    end
  end
end
