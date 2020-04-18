Rails.application.routes.draw do
  devise_for :users
  root to: 'dashboard#index'
  resources :transactions, only: [:index]
  resources :login_items, only: [:index, :destroy]
  post '/plaid/get_access_token', to: 'plaid#get_access_token'
end
