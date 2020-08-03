require 'resque/server'

Rails.application.routes.draw do
  constraints subdomain: 'app' do
    devise_for :users, path: '', path_names: { sign_in: 'login', sign_out: 'logout'}
    root to: 'dashboard#index'
    resources :transactions, only: [:index, :show, :destroy]
    resources :login_items, only: [:index, :destroy]
    resources :categories, only: [:index]
    resources :bank_accounts, only: [:index]
    get '/dashboard/home', to: 'dashboard#home'
    get '/dashboard/transactions', to: 'dashboard#transactions'
    post '/plaid/get_access_token', to: 'plaid#get_access_token'
    post '/plaid/update_link', to: 'plaid#update_link'
    get '/login_items/:id/refresh_transactions/', to: 'login_items#refresh_transactions', as: :refresh_transactions
    get '/login_items/:id/refresh_historical_transactions', to: 'login_items#refresh_historical_transactions', as: :refresh_historical_transactions
    post '/events/login_item_callback', to: 'events#login_item_callback'
    get '/login_items/:id/status', to: 'login_items#status'
    authenticate :user, lambda {|u| u.admin? } do
      mount Resque::Server.new, :at => "/resque"
    end
  end
end
