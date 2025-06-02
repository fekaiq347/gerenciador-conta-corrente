class Correntista < ApplicationRecord
  # 1:1 com ContaCorrente
  has_one :conta_corrente, dependent: :destroy

  # enum para perfil (0 -> NORMAL; 1 -> VIP)
  enum perfil: {
    NORMAL: 0,
    VIP: 1
  }

  # Validações básicas
  validates :nome, presence: true
  validates :conta_numero, presence: true, uniqueness: true, length: { is 5}
  validates :senha, presence: true, length: { is: 4}
  validates :perfil, presence: true
end
