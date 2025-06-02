class SolicitacaoVisita < ApplicationRecord
  # Relacionamentos

  belongs_to :correntista
  belongs_to :movimentacao_debito, class_name: "Movimentacao", optional: true

  # Sem enum!
  
  # Validações
  
  validates :correntista, presence:true
  validate :somente_vip_pode_solicitar
  validates :data_hora_solicitacao, presence: true

  validates :confirmada, inclusion: { in: [true, false] }

  validates :valor_debito, presence: true,
                           numericality: { greater_than: 0, message: "deve ser maior que zero" }

  # Se confirmada for true, tem que existir 'movimentacao_debito_id' depois do fluxo de salvar movimentacao
  validate :movimentacao_debito_deve_ser_presente_se_confirmada

  private

  def somente_vip_pode_solicitar
    return if correntista.nil?

    unless correntista.VIP?
      errors.add(:correntista, "apenas correntista VIP pode solicitar visita do gerente")
    end
  end

  def movimentacao_debito_deve_ser_presente_se_confirmada
    return unless confirmada

    if movimentacao_debito_id.blank?
      errors.add(:movimentacao_debito, "deve estar presente quando a solicitacao já estiver confirmada")
    end
  end
end
