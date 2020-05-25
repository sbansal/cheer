Rails.application.routes.draw do
  devise_for :users
  root to: 'dashboard#index'
  resources :transactions, only: [:index, :show]
  resources :login_items, only: [:index, :destroy]
  resources :categories, only: [:index]
  get '/dashboard/home', to: 'dashboard#home'
  get '/dashboard/transactions', to: 'dashboard#transactions'
  post '/plaid/get_access_token', to: 'plaid#get_access_token'
  get '/login_items/:id/refresh_transactions/', to: 'login_items#refresh_transactions', as: :refresh_transactions
end
