Rails.application.routes.draw do

  # Login/Logout/Dashboard
  get "/login", to: "sessions#new", as: :login
  post "/login", to: "sessions#create"
  delete "/logout", to: "sessions#destroy", as: :logout  

  get "/dashboard", to: "dashboard#index", as: :dashboard
  
  # Resources
  resources :saldos, only: [:index]
  resources :extratos, only: [:index]
  resources :saques, only: [:new, :create]
  resources :transferencias, only: [:new, :create]
  resources :visitas, only: [:new, :create]
  resources :movimentacoes, only: [:index, :create, :show, :destroy]

  # Rotas de conta
  resources :conta, only: [] do
    member do
      get "deposito", to: "movimentacoes#new_deposito", as: :new_deposito
      post "deposito", to: "movimentacoes#create_deposito", as: :create_deposito

      get "saque", to: "movimentacoes#saque", as: :new_saque
      post "saque", to: "movimentacoes#realizar_saque", as: :create_saque
  
      get "extrato", to: "movimentacoes#extrato", as: :extrato
    end
  end

  root to: "sessions#new"
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  #get "up" => "rails/health#show", as: :rails_health_check

  # Defines the root path route ("/")
  # root "posts#index"
end
