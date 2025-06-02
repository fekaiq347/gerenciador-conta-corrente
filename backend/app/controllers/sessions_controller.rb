class SessionsController < ApplicationController

  def create
    logger.debug ">>>> Entrou em SessionsController#create – params: #{params.inspect}"
    puts      ">>>> Entrou em SessionsController#create – params: #{params.inspect}" 
    
    conta = params[:conta_numero]
    senha = params[:senha]

    # Busca correntista pelo número da conta
    correntista = Correntista.find_by(conta_numero: conta)

    if correntista.nil?
      flash.now[:alert] = "Conta inexistente."
      render :new and return
    end

    # Comparar senha em texto simples
    if correntista.senha == senha
      session[:correntista_id] = correntista_id
      flash[:notice] = "Login realizado com sucesso."
      redirect_to root_path
    else
      flash.now[:alert] = "Senha incorreta."
      render :new
    end
  end

  def destroy
    # Trocar de usuário: limpa a sessão atual e redireciona para tela de login
    session.delete(:correntista_id)
    flash[:notice] = "Você saiu da conta."
    redirect_to login_path
  end
end
