require 'resque/server'

Rails.application.routes.draw do
  constraints subdomain: 'app' do
    devise_for :users, path: '', path_names: { sign_in: 'login', sign_out: 'logout'}
    root to: 'dashboard#index'
    resources :transactions, only: [:index, :show, :destroy]
    resources :login_items, only: [:index, :destroy]
    resources :categories, only: [:index]
    resources :bank_accounts
    resources :subscriptions, only: [:index, :destroy]
    get '/search/address', to: 'search#address'
    get '/search/institution', to: 'search#institution'
    get '/dashboard/home', to: 'dashboard#home'
    get '/dashboard/transactions', to: 'dashboard#transactions'
    post '/plaid/generate_access_token', to: 'plaid#generate_access_token'
    post '/plaid/update_link', to: 'plaid#update_link'
    post '/plaid/create_link_token', to: 'plaid#create_link_token'
    get '/login_items/:id/refresh_transactions/', to: 'login_items#refresh_transactions', as: :refresh_transactions
    get '/login_items/:id/refresh_historical_transactions', to: 'login_items#refresh_historical_transactions', as: :refresh_historical_transactions
    post '/events/login_item_callback', to: 'events#login_item_callback'
    get '/login_items/:id/status', to: 'login_items#status'
    get '/bank_accounts/:id/refresh/', to: 'bank_accounts#refresh', as: :refresh_balance
    get 'accounts/settings'
    post '/users/invite_person'
    post '/users/:id/reinvite', to: 'users#reinvite', as: :reinvite_user
    authenticate :user, lambda {|u| u.admin? } do
      mount Resque::Server.new, :at => "/resque"
    end
  end
end
