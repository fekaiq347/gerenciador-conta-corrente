class Transferencia < ApplicationRecord
  # ------------------------------------------------------------
  # Relacionamentos
  # ------------------------------------------------------------
  # origem_conta e destino_conta são registros da tabela conta_correntes
  belongs_to :origem_conta,  class_name: "ContaCorrente", foreign_key: "origem_conta_id"
  belongs_to :destino_conta, class_name: "ContaCorrente", foreign_key: "destino_conta_id", optional: true

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
  before_validation :preencher_destino_pelo_numero

  # ------------------------------------------------------------
  # Validações
  # ------------------------------------------------------------

  # valida se a conta de origem está presente (deve ser setada manualmente no controller)
  validates :origem_conta, presence: true

  # valida formato e presença do número de conta de destino (atributo virtual)
  validates :destino_conta_numero,
            presence: true,
            format: { with: /\A[0-9]{5}\z/, message: "deve conter exatamente 5 dígitos numéricos" }

  # após o callback, verifica se destino_conta_id foi preenchido corretamente
  validates :destino_conta, presence: { message: "não encontrada para o número informado" }

  # Garante que origem e destino sejam diferentes
  validate :contas_origem_destino_diferentes

  validates :valor_transferido,
            presence: true,
            numericality: { greater_than: 0, message: "deve ser maior que 0" }

  validates :tarifa,
            presence: true,
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

  # Converte o atributo virtual `destino_conta_numero` em `destino_conta_id`.
  # Se não encontrar nenhum Correntista com aquele número de conta, adiciona um erro.
  def preencher_destino_pelo_numero
    # Só tenta buscar se o usuário informou algo em destino_conta_numero e ainda não existem erros de formato
    return if destino_conta_numero.blank? || errors.added?(:destino_conta_numero, :invalid)

    # Busca o Correntista pelo número de conta (coluna correntistas.conta_numero)
    correntista_destino = Correntista.find_by(conta_numero: destino_conta_numero)

    if correntista_destino.nil?
      # Se não encontrar, adiciona erro para mostrar que não há conta de destino
      errors.add(:destino_conta_numero, "não corresponde a nenhuma conta")
    else
      # Se encontrar, preenche o destino_conta_id com a ContaCorrente vinculada
      self.destino_conta_id = correntista_destino.conta_corrente&.id

      # Caso o correntista exista, mas ainda não tenha ContaCorrente (época de criação), você pode ajustar aqui:
      if destino_conta_id.nil?
        errors.add(:destino_conta_numero, "não possui conta corrente ativa")
      end
    end
  end

  # Garante que a conta de origem e a de destino não sejam a mesma
  def contas_origem_destino_diferentes
    # Só valida se ambos os IDs estiverem presentes
    return if origem_conta_id.blank? || destino_conta_id.blank?

    if origem_conta_id == destino_conta_id
      errors.add(:destino_conta, "não pode ser igual à conta de origem")
    end
  end
end
