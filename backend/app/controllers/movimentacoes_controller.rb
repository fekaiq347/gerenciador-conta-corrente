class MovimentacoesController < ApplicationController
  before_action :require_login
  before_action :set_conta, only: [:saque, :realizar_saque, :new_deposito, :create_deposito]
  
  # get /contas/:conta_id/saque
  def saque
    
  end

  # post /contas/:conta_id/realizar_saque
  def realizar_saque
    valor = params[:valor_saque].to_f

    begin
      SaqueService.new(conta: @conta, valor_saque: valor).executar!

      flash[:notice] = "Saque de R$%.2f realizado com sucesso." % valor
      redirect_to extrato_conta_path(@conta), status: :see_other
    rescue StandardError => e
      flash[:alert] = e.message
      redirect_to saque_conta_path(@conta), status: :see_other
    end
  end

  # get /conta/deposito
  def new_deposito
    # @conta já está setada pelo callback :set_conta
  end

  # post /conta/deposito
  def create_deposito
    valor = params[:valor].to_s.gsub(",", ".").to_f

    begin
      DepositoService.new(conta: @conta, valor_deposito: valor).executar!
      flash[:notice] = "Depósito de R$%2.f realizado com sucesso." % valor
      redirect_to dashboard_path, status: :see_other
    rescue StandardError => e
      flash.now[:alert] = e.message
      render :new_deposito
    end
  end

  private

  def set_conta
    @conta = current_correntista.conta_corrente
  end
end
