Rails.application.routes.draw do
  # Login / Logout / Dashboard
  get    "/login",  to: "sessions#new",     as: :login
  post   "/login",  to: "sessions#create"
  delete "/logout", to: "sessions#destroy", as: :logout  

  get "/dashboard", to: "dashboard#index", as: :dashboard
  
  # Recursos gerais 
  resources :saldos,       only: [:index]
  resources :extratos,     only: [:index]
  resources :movimentacoes, only: [:index, :create, :show, :destroy]

  # Rotas
  resources :contas, only: [] do
    member do
      # ─── Saque ───────────────────────────────────────────────────────────
      # GET  /contas/:conta_id/saque     → MovimentacoesController#saque
      # POST /contas/:conta_id/saque     → MovimentacoesController#realizar_saque
      get  "saque", to: "movimentacoes#saque",            as: :new_saque
      post "saque", to: "movimentacoes#realizar_saque",   as: :create_saque

      # ─── Depósito ────────────────────────────────────────────────────────
      # GET  /contas/:conta_id/deposito  → MovimentacoesController#new_deposito
      # POST /contas/:conta_id/deposito  → MovimentacoesController#create_deposito
      get  "deposito", to: "movimentacoes#new_deposito",    as: :new_deposito
      post "deposito", to: "movimentacoes#create_deposito", as: :create_deposito

      # ─── Transferência ───────────────────────────────────────────────────
      # GET  /contas/:conta_id/transferencia  → TransferenciasController#new
      # POST /contas/:conta_id/transferencia  → TransferenciasController#create
      get  "transferencia", to: "transferencias#new",    as: :new_transferencia
      post "transferencia", to: "transferencias#create", as: :create_transferencia

      # ─── Extrato ──────────────────────────────────────────────────────────
      # GET /contas/:conta_id/extrato   → MovimentacoesController#extrato
      get  "extrato", to: "movimentacoes#extrato",        as: :extrato

      # ─── Visita do gerente (somente para VIP) ─────────────────────────────
      # GET  /contas/:conta_id/visita   → VisitasController#new
      # POST /contas/:conta_id/visita   → VisitasController#create
      get  "visita", to: "visitas#new",    as: :new_visita
      post "visita", to: "visitas#create", as: :create_visita
    end
  end

  # Rota raiz
  root to: "sessions#new"
end

