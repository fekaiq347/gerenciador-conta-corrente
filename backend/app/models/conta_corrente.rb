class ContaCorrente < ApplicationRecord
  belongs_to :correntista
  has_many :movimentacoes, class_name: "Movimentacao", foreign_key: "conta_corrente_id", dependent: :destroy
  # Validações
  validates :correntista, presence:true
  validate :saldo_nao_excede_limite_por_perfil
  validates :esta_negativo, inclusion: { in: [true, false] }
  validates :correntista_id, uniqueness: true
 
  # Callback pra controlar flags de negativo e timestamp
  before_save :atualizar_indicadores_negativo

  def saldo_negativo?
    (saldo || 0.0) < 0.0
  end
 
  def minutos_em_negativo
      return 0 unless data_hora_primeiro_negativo

      ((Time.current - data_hora_primeiro_negativo) / 60).floor
  end

  def penalidade_acumulada
      return 0 unless saldo.negativo? && data_hora_primeiro_negativo

      saldo_neg_abs = saldo.abs
      (saldo_neg_abs * 0.001 * minutos_em_negativo).round(2)
  end

  def marcar_como_negativo!
      return if data_hora_primeiro_negativo.present?

      self.esta_negativo = true
      self.data_hora_primeiro_negativo = Time.current
      save!(validate: false)
  end

  def resetar_negativo!
    self.esta_negativo = false
    self.data_hora_primeiro_negativo = nil
    save!(validate: false)
  end

  private

  def saldo_nao_excede_limite_por_perfil
    return if correntista.nil?

    # Usuário normal e saldo menor que 0, block
    if correntista.normal? && (saldo || 0.0) < 0.0
      errors.add(:saldo, "conta não pode ficar negativa para perfil NORMAL")
    end
  end

  def atualizar_indicadores_negativo
    if (saldo || 0.0) < 0.0
      self.esta_negativo = true

      if correntista&.vip? && data_hora_primeiro_negativo.nil?
        self.data_hora_primeiro_negativo = Time.current
      end
    else
      self.esta_negativo = false
      self.data_hora_primeiro_negativo = nil
    end
  end
end
