class MovimentacoesController < ApplicationController
  before_action :require_login
  before_action :set_conta, only: [:saque, :realizar_saque, :new_deposito, :create_deposito, :extrato]
  
  # get /contas/:conta_id/saque
  def saque
    
  end

  # post /contas/:conta_id/realizar_saque
  def realizar_saque
    raw_valor = params[:valor_saque].to_s.strip
    valor = raw_valor.gsub(",", ".").to_f

    begin
      SaqueService.new(conta: @conta, valor_saque: valor).executar!
      flash[:notice] = "Saque de R$%.2f realizado com sucesso." % valor
      redirect_to extrato_conta_path(@conta), status: :see_other
    rescue StandardError => e
      flash[:alert] = e.message
      render :saque, status: :unprocessable_entity
    end
  end

  # get /conta/deposito
  def new_deposito
    # @conta já está setada pelo callback :set_conta
  end

  # post /conta/deposito
  def create_deposito
    raw_valor = params[:valor_deposito].to_s.strip
    valor = raw_valor.gsub(",", ".").to_f

    begin
      DepositoService.new(conta: @conta, valor_deposito: valor).executar!
      flash[:notice] = "Depósito de R$%.2f realizado com sucesso." % valor
      redirect_to extrato_conta_path(@conta), status: :see_other
    rescue StandardError => e
      flash.now[:alert] = e.message
      render :new_deposito, status: :unprocessable_entity
    end
  end

  def extrato
    @movimentacoes = @conta.movimentacoes.order(created_at: :desc)
  end



  private

  def set_conta
    @conta = current_correntista.conta_corrente
  end
end
