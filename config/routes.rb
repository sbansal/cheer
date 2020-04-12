Rails.application.routes.draw do
  devise_for :users
  root to: 'dashboard#home'
  resources :transactions, only: [:index]
  post '/plaid/get_access_token', to: 'plaid#get_access_token'
end
