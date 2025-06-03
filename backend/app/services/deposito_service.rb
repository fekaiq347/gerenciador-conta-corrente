class DepositoService
  attr_reader :conta, :valor_deposito

  def initialize(conta:, valor_deposito:)
    @conta = conta
    @valor_deposito = valor_deposito.to_f
  end

  def executar!
    raise ArgumentError, "Valor de depósito inválido" if valor_deposito <= 0

    # Antes de creditar, se já tava negativo, calcula penalidade pendente
    if conta.esta_negativo
      aplicar_penalidade_pendente!
    end

    Movimentacao.create!(
      conta_corrente: conta,
      tipo: :deposito,
      descricao: "Depósito de R$%.2f" % valor_deposito,
      valor: valor_deposito,
        data_hora: Time.current
    )

    novo_saldo = conta.saldo + valor_deposito
    conta.update!(saldo: novo_saldo)

    # se o saldo ficou positivo após estar negativado, reseta a flag
    if conta.esta_negativo && novo_saldo >= 0
      conta.resetar_negativo!
    end

    return true
  end

  private

  def aplicar_penalidade_pendente!
    penalidade = conta.penalidade_acumulada
    return if penalidade <= 0
    
    Movimentacao.create!(
      conta_corrente: conta,
      tipo: :penalidade_saldo_negativo,
      descricao: "Penalidade por saldo negativo até #{Time.current.strftime('%d/%m/%Y %H:%M')}",
      valor: -penalidade,
      data_hora: Time.current
    )

    novo_saldo = conta.saldo - penalidade
    conta.update!(saldo: novo_saldo)

    # se, depois da penalidade, saldo == 0 ou >0 limpar flags
    conta.resetar_negativo! if novo_saldo >= 0
  end
end
