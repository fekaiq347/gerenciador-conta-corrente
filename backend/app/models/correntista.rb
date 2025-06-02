class Correntista < ApplicationRecord
  self.table_name = "correntistas"
  # 1:1 com ContaCorrente
  has_one :conta_corrente, dependent: :destroy
  has_many :solicitacao_visitas, dependent: :destroy
  # enum para perfil (0 -> NORMAL; 1 -> VIP)
  enum perfil: {
    NORMAL: 0,
    VIP: 1
  }

  # Validações básicas
  validates :nome, presence: true
  validates :conta_numero, presence: true, uniqueness: true, format: { with: /\A\d{5}\z/, message: "deve ter exatamente 5 dígitos numéricos" }
  validates :senha, presence: true, format: { with: /\A\d{4}\z/, message: "deve ter exatamente 4 dígitos numéricos" }
  validates :perfil, presence: true
  validates :conta_corrente, presence: true
end
