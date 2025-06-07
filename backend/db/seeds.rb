# db/seeds.rb

# Senha em texto simples 

c = Correntista.find_or_initialize_by(conta_numero: "12345")
  c.nome      = "Cliente Normal"
  c.senha     = "1010"
  c.perfil    = "normal"

  c.build_conta_corrente(
    saldo: 1000.00,
    esta_negativo: false,
    data_hora_primeiro_negativo: nil
  )

  c.save!

c = Correntista.find_or_initialize_by(conta_numero: "54321")
  c.nome      = "Cliente VIP"
  c.senha     = "0101"
  c.perfil    = "vip"
  
  c.build_conta_corrente(
    saldo: 5000.00,
    esta_negativo: false,
    data_hora_primeiro_negativo: nil
  )

  c.save!
