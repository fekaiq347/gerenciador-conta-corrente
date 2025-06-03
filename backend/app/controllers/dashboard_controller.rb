class DashboardController < ApplicationController
  before_action :require_login

  def index
    # um exemplo qualquer
    @conta = current_correntista.conta_corrente
  end
end
