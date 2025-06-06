module ApplicationHelper
  def saudacao_por_horario
    hora = Time.zone.now.hour
    if hora < 12
      "Bom dia"
    elsif hora < 18
      "Boa tarde"
    else
      "Boa noite"
    end
  end
end
