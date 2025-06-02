class ContaCorrente < ApplicationRecord
  belongs_to :correntista
  has_many :movimentacoes, dependent: :destroy
  # Validações
  validates :correntista, presence:true
  validate :saldo_nao_excede_limite_por_perfil
  validates :esta_negativo, inclusion: { in: [true, false] }
  validates :correntista_id, uniqueness: true
  # Callback pra controlar flags de negativo e timestamp
  before_save :atualizar_indicadores_negativo

  private

  def saldo_nao_excede_limite_por_perfil
    return if correntista.nil?

    # Usuário normal e saldo menor que 0, block
    if correntista.NORMAL? && saldo < 0
      errors.add(:saldo, "conta não pode ficar negativa para perfil NORMAL")
    end
  end

  def atualizar_indicadores_negativo
    if saldo < 0
      self.esta_negativo = true

      if correntista.VIP? && data_hora_primeiro_negativo.nil?
        self.data_hora_primeiro_negativo = TIME.current
      end
    else
      self.esta_negativo = false
      self.data_hora_primeiro_negativo = nil
    end
  end
end
