class Movimentacao < ApplicationRecord
  belongs_to :conta_corrente
  belongs_to :transferencia, optional: true
  
  has_one :solicitacao_visita, foreign_key: "movimentacao_debito_id", dependent: :nullify

  # lembrar de deixar minúsuclo
  enum tipo: {
    saque:                      0,
    deposito:                   1,
    transferencia_out:          2,
    transferencia_in:           3,
    tarifa_transferencia:       4,
    penalidade_saldo_negativo:  5,
    debito_visita_gerente:      6
  }

  validates :conta_corrente, presence: true
  
  validates :tipo, presence: true,
                   inclusion: { in: tipos.keys.map(&:to_s), message: "inválido" }
  
  validates :valor, presence: true,
                    numericality: true

  validates :data_hora, presence: true

  validates :descricao, presence: true, length: { maximum: 255}
  
  # Se 'tipo' estiver relacionado a transferencia ou tarifa, 'transferencia_id' deve existir ou ser nulo apropriadamente
  validate :transferencia_deve_ser_presente_quando_necessario

  # Valor positivo para entradas e negativo para saídas
  validate :valor_corresponde_ao_tipo

  private

    def transferencia_deve_ser_presente_quando_necessario
      tipos_com_transferencia = %w[transferencia_out transferencia_in tarifa_transferencia]

      if tipos_com_transferencia.include?(tipo) && transferencia_id.blank?
        errors.add(:transferencia, "deve ser informada para tipo #{tipo}") 
      end

      if transferencia_id.present? && !tipos_com_transferencia.include?(tipo)
        errors.add(:transferencia, "só pode ser preenchida para tipos de transferência")
      end
  end

  def valor_corresponde_ao_tipo
    return if valor.blank? || tipo.blank?

    case tipo
    when "saque", "transferencia_out", "tarifa_transferencia", "penalidade_saldo_negativo", "debito_visita_gerente"
      if valor >= 0
        errors.add(:valor, "deve ser negativo para o tipo #{tipo}")
      end
    when "deposito", "transferencia_in"
      if valor <= 0
        errors.add(:valor, "deve ser positivo para o tipo #{tipo}")
      end
    end
  end
end
