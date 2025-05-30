# Gerenciador de Conta Corrente

Este é um projeto desenvolvido como parte de um desafio técnico de estágio. A proposta consiste na criação de um sistema bancário simples, com funcionalidades essenciais para gestão de contas correntes. O sistema é construído utilizando boas práticas de desenvolvimento, separação entre frontend e backend, e containerização com Docker.

## Tecnologias Utilizadas

* **Backend**: Ruby on Rails (modo API)
* **Frontend**: React + Vite + Tailwind CSS
* **Banco de dados**: PostgreSQL
* **Containerização**: Docker + Docker Compose
* **Versionamento**: Git + GitHub

## Funcionalidades Implementadas

* Login com conta corrente (5 dígitos) e senha (4 dígitos)
* Visualização de saldo
* Emissão de extrato com data, hora, descrição e valor
* Saques (com regras para perfis Normal e VIP)
* Depósitos
* Transferências (com tarifas e limites por perfil)
* Solicitação de visita do gerente (VIP apenas)
* Troca de usuário (logout/login)

## Regras de Negócio

* **Normal**:

  * Sem saldo negativo permitido
  * Limite de transferência: R\$1000
  * Tarifa fixa por transferência: R\$8
* **VIP**:

  * Pode sacar além do saldo (com penalidade de 0,1% por minuto de saldo negativo)
  * Sem limite de transferência
  * Tarifa: 0,8% do valor transferido
  * Pode solicitar visita do gerente (R\$50)

## Correntistas de Teste

Dois correntistas são pré-cadastrados:

| Conta | Senha | Perfil |
| ----- | ----- | ------ |
| 12345 | 1234  | Normal |
| 54321 | 4321  | VIP    |

## Como Executar

1. Clone o repositório:

```bash
git clone https://github.com/seu-usuario/gerenciador-conta-corrente.git
cd gerenciador-conta-corrente
```

2. Suba os containers com Docker Compose:

```bash
docker-compose up --build
```

3. Acesse os serviços:

* Frontend: [http://localhost:5173](http://localhost:5173)
* Backend: [http://localhost:3000](http://localhost:3000)

## Testes

Os testes unitários (quando implementados) podem ser executados com:

```bash
docker-compose exec backend bundle exec rspec
```

## Licença

Projeto para fins de avaliação técnica. Não possui finalidade comercial.
