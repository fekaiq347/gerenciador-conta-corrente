class TransferenciaService
  attr_reader :origem, :destino, :valor_transferido, :tarifa

  # a origem é ContaCorrente e já está carregada no controller
  # destino_numero é string porque é o número da conta 
  # raw_valor é string também
  
  def initialize(origem:, destino_numero:, raw_valor:)
    @origem = origem

    corr_correntista= Correntista.find_by(conta_numero: destino_numero)

    @destino = corr_correntista&.conta_corrente
    @valor_transferido = parse_valor(raw_valor)
    @tarifa = 0
  end

  def executar!
    # Primeiras validações
    raise ArgumentError, "Conta de destino não existe." if destino.nil?
    if origem.id == destino.id
      raise StandardError, "Não é possível transferir para a mesma conta."
    end

    # Restrição de valor para cliente normal
    if origem.correntista.normal? && valor_transferido > 1000.0
      raise StandardError, "Usuário NORMAL só pode transferir até R$1.000,00."
    end

    calcular_tarifa!

    # criar registro em Transferencia
    transferencia = Transferencia.create!(
      origem_conta_id: origem.id,
      destino_conta_id: destino.id,
      valor_transferido: valor_transferido,
      tarifa: tarifa,
      data_hora: Time.current
    )

    # movimentações associadas
    # transferencia_out (origem): -valor_transferido
    Movimentacao.create!(
      conta_corrente: origem,
      tipo: :transferencia_out,
      descricao: "Transferência de R$%.2f para conta #{destino.correntista.conta_numero}" % valor_transferido,
      valor: -valor_transferido,
      data_hora: Time.current,
      transferencia: transferencia
    )

    # tarifa_transferencia (origem): -tarifa
    Movimentacao.create!(
      conta_corrente: origem,
      tipo: :tarifa_transferencia,
      descricao: "Tarifa de transferência R$%.2f" % tarifa,
      valor: -tarifa,
      data_hora: Time.current,
      transferencia: transferencia
    )

    # transferencia_in (destino): +valor_transferido
    Movimentacao.create!(
      conta_corrente: destino,
      tipo: :transferencia_in,
      descricao: "Recebimento de R$%.2f da conta #{origem.conta_numero}" % valor_transferido,
      valor: valor_transferido,
      data_hora: Time.current,
      transferencia: transferencia
    )

    # atualização dos saldos
    novo_saldo_origem = origem.saldo - valor_transferido - tarifa
    novo_saldo_destino = destino.saldo + valor_transferido

    origem.update!(saldo: novo_saldo_origem)
    destino.update!(saldo: novo_saldo_destino)

    # se a conta de origem for VIP e ficou negativa, marca como negativo (para receber penalidade no futuro)
    if origem.correntista.vip? && novo_saldo_origem < 0
      origem.marcar_como_negativo! if origem.data_hora_primeiro_negativo.nil?
    end

    transferencia
  end

  private

  def parse_valor(raw)
    return 0.0 if raw.blank?
    raw.to_s.strip.gsub(",", ".").to_f
  end

  def calcular_tarifa!
    if origem.correntista.normal?
      @tarifa = 8.0
    else
      @tarifa = (valor_transferido * 0.008).round(2)
    end
  end
end
