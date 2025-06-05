class TransferenciasController < ApplicationController
  before_action :require_login
  before_action :set_conta_origem, only: [:new, :create]

  # GET /transferencias/new
  def new
    # Instancia um objeto Transferencia vazio, para o form “model-backed”
    @transferencia = Transferencia.new
  end

  # POST /transferencias
  def create
    # Cria um Transferencia a partir dos parâmetros permitidos (inclui o destino_conta_numero)
    @transferencia = Transferencia.new(transferencia_params)

    # Seta a conta de origem e a data/hora antes de salvar
    @transferencia.origem_conta_id = @conta_origem.id
    @transferencia.data_hora       = Time.current

    # Aqui, dispara as validações do model:
    #  - formato/presença de destino_conta_numero
    #  - callback before_validation que converte destino_conta_numero → destino_conta_id
    #  - validações de valor_transferido, tarifa e contas diferentes
    if @transferencia.valid?
      begin
        # Se tudo estiver válido, invoca o seu serviço
        svc = TransferenciaService.new(
          origem:         @conta_origem,
          destino_numero: @transferencia.destino_conta_numero,
          raw_valor:      @transferencia.valor_transferido.to_s
        )
        transferencia_executada = svc.executar!

        numero_destino_atual = transferencia_executada
                                 .destino_conta
                                 .correntista
                                 .conta_numero

        flash[:notice] = "Transferência de R$%.2f para conta #{numero_destino_atual} realizada com sucesso." % svc.valor_transferido
        redirect_to extrato_conta_path(@conta_origem), status: :see_other
      rescue StandardError => e
        # Se o serviço lançar erro, reexibe o form com a mensagem
        flash.now[:alert] = e.message
        render :new, status: :unprocessable_entity
      end
    else
      # Se falhar nas validações do model, reexibe o form com os erros
      render :new, status: :unprocessable_entity
    end
  end

  private

  # Recupera a ContaCorrente do usuário logado
  def set_conta_origem
    @conta_origem = current_correntista.conta_corrente
  end

  # Só permitimos esses campos do form
  def transferencia_params
    params.require(:transferencia).permit(:destino_conta_numero, :valor_transferido)
  end
end

