class Transferencia < ApplicationRecord
  # ------------------------------------------------------------
  # Relacionamentos
  # ------------------------------------------------------------
  # origem_conta e destino_conta são registros da tabela conta_correntes
  belongs_to :origem_conta,  class_name: "ContaCorrente", foreign_key: "origem_conta_id"
  belongs_to :destino_conta, class_name: "ContaCorrente", foreign_key: "destino_conta_id"

  # Toda transferência poderá gerar várias movimentações
  has_many :movimentacoes, dependent: :destroy

  # ------------------------------------------------------------
  # Atributo virtual para receber o número de conta (5 dígitos)
  # ------------------------------------------------------------
  # Esse campo NÃO existe na tabela, mas será preenchido pelo form
  # e usado para buscar o correntista → conta_corrente de destino.
  attr_accessor :destino_conta_numero

  # ------------------------------------------------------------
  # Callbacks
  # ------------------------------------------------------------
  # Antes de validar, iremos converter destino_conta_numero → destino_conta_id
  before_validation :atribui_destino_conta_id
  before_validation :normalizar_valor_transferido
  # ------------------------------------------------------------
  # Validações
  # ------------------------------------------------------------

  # valida se a conta de origem está presente (deve ser setada manualmente no controller)
  validates :origem_conta, presence: true

  # valida formato e presença do número de conta de destino (atributo virtual)
  validates :destino_conta_numero,
            presence: true,
            format: { with: /\A[0-9]{5}\z/, message: "deve conter exatamente 5 dígitos numéricos" },
            if: -> { destino_conta_id.blank?}

  # após o callback, verifica se destino_conta_id foi preenchido corretamente
  validates :destino_conta, presence: { message: "não encontrada para o número informado" }

  # Garante que origem e destino sejam diferentes
  validate :contas_origem_destino_diferentes

  validates :valor_transferido,
            presence: true,
            numericality: { greater_than: 0, message: "deve ser maior que 0" }

  validates :tarifa,
            numericality: { greater_than_or_equal_to: 0, message: "não pode ser negativa" }

  validates :data_hora,
            presence: { message: "não pode ficar em branco" }

  # ------------------------------------------------------------
  # Métodos privados
  # ------------------------------------------------------------
  private

  def normalizar_valor_transferido
    return if valor_transferido.blank?

    texto = valor_transferido.to_s.strip

    texto = texto.tr(",",".")

    self.valor_transferido = texto
  end
  
  def atribui_destino_conta_id
    return if destino_conta_numero.blank?

    correntista_destino = Correntista.find_by(conta_numero: destino_conta_numero)
    
    if correntista_destino.nil?
      errors.add(
        :destino_conta_numero,
        "não corresponde a nenhuma conta de destino válida"
      )
      return
    end

    conta_corrente = correntista_destino.conta_corrente
  
    if conta_corrente.nil?
      errors.add(:destino_conta_numero, "não possui conta corrente ativa")
      return
    end

    self.destino_conta_id = conta_corrente.id
  end

  def contas_origem_destino_diferentes
    return if origem_conta_id.blank? || destino_conta_id.blank?

    if origem_conta_id == destino_conta_id
      errors.add(
        :destino_conta,
        "não pode ser igual à conta de origem"
      )
    end
  end
end
