class VisitasController < ApplicationController
  before_action :require_login
  before_action :set_conta
  before_action :verificar_vip_e_dono_da_conta

  def new

  end

  def create
    ActiveRecord::Base.transaction do
      movimentacao = @conta.movimentacoes.create!(
        tipo: :debito_visita_gerente,
        valor: -50.0,
        descricao: "Visita gerente",
        data_hora: Time.current
      )

      novo_saldo = @conta.saldo - 50.0
      @conta.update!(saldo: novo_saldo)

      current_correntista.solicitacao_visitas.create!(
        data_hora_solicitacao: Time.current,
        confirmada: true,
        valor_debito: 50.0,
        movimentacao_debito: movimentacao
      )
    end

    redirect_to extrato_conta_path(@conta), notice: "Solicitação de visita enviada e débito de R$50,00 realizado com sucesso."
  rescue ActiveRecord::RecordInvalid => e
    flash[:alert] = e.record.errors.full_messages.join(", ")
    redirect_to new_visita_conta_path(@conta), status: :see_other
  end
  
  private
    
  def set_conta
    @conta = ContaCorrente.find(params[:id])
  end

  def verificar_vip_e_dono_da_conta
    unless current_correntista.vip? && current_correntista.conta_corrente == @conta
      redirect_to dashboard_path, alert: "Acesso negado."
    end
  end
end
