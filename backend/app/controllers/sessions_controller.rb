class SessionsController < ApplicationController
  skip_before_action :require_login, only: %i[new create]

  def new
    redirect_to dashboard_path, status: :see_other if logged_in?
  end

  def create 
    conta = params[:conta_numero]
    senha = params[:senha]

    unless conta =~ /\A\d{5}\z/
      flash.now[:alert] = "O número da conta deve conter exatamente 5 dígitos numéricos."
      render :new, status: :unprocessable_entity and return
    end

    unless senha =~ /\A\d{4}\z/
      flash.now[:alert] = "A senha deve conter exatamente 4 dígitos numéricos."
      render :new, status: :unprocessable_entity and return
    end
    # Busca correntista pelo número da conta
    correntista = Correntista.find_by(conta_numero: conta)

    if correntista.nil?
      flash.now[:alert] = "Conta inexistente."
      render :new, status: :unprocessable_entity and return
    end

    # Comparar senha em texto simples
    if correntista.senha == senha
      session[:correntista_id] = correntista.id
      flash[:notice] = "Login realizado com sucesso."
      redirect_to dashboard_path, status: :see_other
    else
      flash.now[:alert] = "Senha incorreta."
      render :new, status: :unprocessable_entity
    end
  end

  def destroy
    # Trocar de usuário: limpa a sessão atual e redireciona para tela de login
    session.delete(:correntista_id)
    flash[:notice] = "Você saiu da conta."
    redirect_to login_path
  end
end
