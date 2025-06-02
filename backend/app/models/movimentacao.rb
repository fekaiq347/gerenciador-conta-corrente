class Movimentacao < ApplicationRecord
  belongs_to :conta_corrente
  belongs_to :transferencia, optional: true
  
  has_one :solicitacao_visita, foreign_key: "movimentacao_debito_id", dependent: :nullify

  enum tipo: {
    SAQUE:                      0,
    DEPOSITO:                   1,
    TRANSFERENCIA_OUT:          2,
    TRANSFERENCIA_IN:           3,
    TARIFA_TRANSFERENCIA:       4,
    PENALIDADE_SALDO_NEGATIVO:  5,
    DEBITO_VISITA_GERENTE:      6
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
      tipos_com_transferencia = %w[TRANSFERENCIA_OUT TRANSFERENCIA_IN TARIFA_TRANSFERENCIA]

      if tipos_com_transferencia.include?(tipo) && transferencia_id.blank?
        errors.add(:transferencia, "deve ser informada para tipo #{tipo}") 
      end

      unless tipos_com_transferencia.include?(tipo) || transferencia_id.blank?
        errors.add(:transferencia, "só pode ser preenchida para tipos de transferência")
      end
  end

  def valor_corresponde_ao_tipo
    return if valor.blank? || tipo.blank?

    case tipo
    when "SAQUE", "TRANSFERENCIA_OUT", "TARIFA_TRANSFERENCIA", "PENALIDADE_SALDO_NEGATIVO", "DEBITO_VISITA_GERENTE"
      if valor >= 0
        errors.add(:valor, "deve ser negativo para o tipo #{tipo}")
      end
    when "DEPOSITO", "TRANSFERENCIA_IN"
      if valor <= 0
        errors.add(:valor, "deve ser positivo para o tipo #{tipo}")
      end
    end
  end
end
