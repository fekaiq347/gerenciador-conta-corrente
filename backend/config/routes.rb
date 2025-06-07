Rails.application.routes.draw do
  # Login / Logout / Dashboard
  get    "/login",  to: "sessions#new", as: :login
  post   "/login",  to: "sessions#create"
  delete "/logout", to: "sessions#destroy", as: :logout  

  get "/dashboard", to: "dashboard#index", as: :dashboard
  
  # Recursos gerais 
  resources :saldos, only: [:index]
  resources :extratos, only: [:index]
  resources :movimentacoes, only: [:index, :create, :show, :destroy]

  # Rotas
  resources :contas, only: [] do
    member do
      get  "saque", to: "movimentacoes#saque", as: :new_saque
      post "saque", to: "movimentacoes#realizar_saque", as: :create_saque

      get  "deposito", to: "movimentacoes#new_deposito", as: :new_deposito
      post "deposito", to: "movimentacoes#create_deposito", as: :create_deposito

      get  "transferencia", to: "transferencias#new", as: :new_transferencia
      post "transferencia", to: "transferencias#create", as: :create_transferencia

      get  "extrato", to: "movimentacoes#extrato", as: :extrato

      get  "visita", to: "visitas#new", as: :new_visita
      post "visita", to: "visitas#create", as: :create_visita
    end
  end

  # Rota raiz
  root to: "sessions#new"
end

