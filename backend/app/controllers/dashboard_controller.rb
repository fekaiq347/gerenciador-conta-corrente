class DashboardController < ApplicationController
  before_action :require_login

  def index
    # um exemplo qualquer
    @saldo = current_correntista.conta_corrente.saldo
  end
end
