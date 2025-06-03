class SaqueService
  attr_reader :conta, :valor_saque, :usuario

  # tipo_de_movimentacao pode ser :saque, :penalidade, etc

  def initialize(conta:, valor_saque:)
    @conta = conta
    @valor_saque = valor_saque.to_f
    @usuario = conta.correntista
  end

  def executar!
    raise ArgumentError, "Valor de saque inválido" if valor_saque <= 0

    if usuario.normal?
      valida_normal!
    elsif usuario.vip?
      trata_vip!
    else
      raise "Perfil de usuário desconhecido"
    end

    # Cria movimentação de saque
    Movimentacao.create!(
      conta_corrente: conta,
      tipo: :saque,
      descricao: "Saque de R$%.2f" % valor_saque,
      valor: -valor_saque,
      data_hora: Time.current
    )


    conta.update!(saldo: conta.saldo - valor_saque)

    # Se vip ficou negativado, marca a primeira data_hora_primeiro_negativo
    if usuario.vip? && conta.saldo < 0
      conta.marcar_como_negativo!
    end

    return true
  end

  private

  def valida_normal!
    if valor_saque > conta.saldo
      raise StandardError, "Saldo insuficiente"
    end
  end

  def trata_vip!
    # Se já está negativo, aplica penalidade pendente antes de continuar
    if conta.esta_negativo
      aplicar_penalidade_pendente!
    end
    # Tem que lembrar que vip saca qualquer valor, com saldo ou não
  end

  def aplicar_penalidade_pendente!
    penalidade = conta.penalidade_acumulada
    return if penalidade <= 0

    # mov penalidade
    Movimentacao.create!(
      conta_corrente: conta,
      tipo: :penalidade_saldo_negativo,
      descricao: "Penalidade por saldo negativo até #{Time.current.strftime('%d/%m/%Y %H:%M')}",
      valor: -penalidade,
      data_hora: Time.current
    )

    # debitar do saldo
    novo_saldo = conta.saldo - penalidade
    conta.update!(saldo: novo_saldo)

    if novo_saldo >= 0
      conta.resetar_negativo!
    end
  end
end
