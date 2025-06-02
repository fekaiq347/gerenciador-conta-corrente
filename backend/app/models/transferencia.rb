class Transferencia < ApplicationRecord
  
  # Relacionamentos
  belongs_to :origem_conta, class_name: "ContaCorrente", foreign_key: "origem_conta_id"

  belongs_to :destino_conta, class_name: "ContaCorrente", foreign_key: "destino_conta_id"

  has_many :movimentacoes, dependent: :destroy

  # Validações
  validates :origem_conta, presence: true
  validates :destino_conta, presence: true

  # Origem e destino não podem ser a mesma conta
  validate :contas_origem_destino_diferentes

  validates :valor_transferido, presence: true,
                                numericality: { greater_than: 0, message: "deve ser maior que 0" }
  validates :tarifa, presence: true,
                     numericality: { greater_than_or_equal_to: 0, message: "não pode ser negativa" }

  validates :data_hora, presence: true

  private

  # Vai garantir que a conta de origem e a conta de destino sejam diferentes
  def contas_origem_destino_diferentes
    return if origem_conta_id.blank? || destino_conta_id.blank?

    if origem_conta_id == destino_conta_id
      errors.add(:destino_conta, "não pode ser igual à conta de origem")
    end
  end
end
