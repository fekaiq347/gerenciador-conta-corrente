class DashboardController < ApplicationController
  before_action :require_login

  def index
    @conta = current_correntista.conta_corrente
    @saldo = @conta.saldo
    flash.clear
  end
end
