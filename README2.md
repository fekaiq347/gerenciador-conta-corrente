# Gerenciador de Conta Corrente 

Desafio técnico de estágio — sistema bancário com funcionalidades de saque, depósito, transferência, extrato, visita do gerente e troca de usuário.

---

## Visão Geral

Este projeto implementa um gerenciador de conta corrente para dois perfis de usuário (NORMAL e VIP), com:

- **Login simples** (conta de 5 dígitos + senha de 4 dígitos)  
- **Saldo**  
- **Extrato** (data, hora, descrição e valor; parênteses se negativo)  
- **Saque** (regras diferentes para NORMAL e VIP)  
- **Depósito**  
- **Transferência** (valores permitidos e tarifas por perfil)  
- **Solicitação de visita do gerente** (apenas VIP)  
- **Troca de usuário** sem necessidade de reiniciar a aplicação  

---

## Stack Tecnológica

- **Backend:** Ruby on Rails 7.1  
- **Banco de dados:** PostgreSQL  
- **Containerização:** Docker & Docker Compose  
- **Front-end:** Bootstrap via CDN (interface web simples)  
- **Versionamento:** Git & GitHub  

---

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

---

## Pré-requisitos

- [Docker](https://www.docker.com/)  
- [Docker Compose](https://docs.docker.com/compose/)  

---

## Como Executar

1. Certifique-se de que Docker e Docker Compose estão instalados.  
2. No diretório raiz do projeto, dê permissão e execute o script:

```bash
   chmod +x start.sh
   ./start.sh
````

Esse script fará:

* `docker-compose up -d --build`
* `bundle install` dentro do container **backend**
* `rails db:setup` (criação, migração e seed do banco)

3. Acesse a aplicação em:

   ```
   http://localhost:3000
   ```

---

## Seeds de Teste

Ao rodar `rails db:setup`, são criados dois correntistas em **db/seeds.rb**:

| Nome           | Conta | Senha | Perfil |
| -------------  | ----- | ----- | ------ |
| Cliente NORMAL | 12345 | 1010  | NORMAL |
| Cliente VIP    | 54321 | 0101  | VIP    |

---

## Modelagem de Dados

### Entidades Principais

1. **Correntista**

   * `id`, `nome`, `conta_numero (char(5))`, `senha (char(4))`, `perfil (ENUM: NORMAL | VIP)`

2. **ContaCorrente**

   * `id`, `correntista_id (1:1)`, `saldo (decimal)`, `esta_negativo (boolean)`, `data_hora_primeiro_negativo (timestamp)`

3. **Movimentacao**

   * `id`, `conta_corrente_id (N:1)`, `tipo (ENUM: SAQUE, DEPOSITO, TRANSFERENCIA\_OUT, TRANSFERENCIA\_IN, TARIFA\_TRANSFERENCIA, PENALIDADE\_SALDO\_NEGATIVO, DEBITO\_VISITA\_GERENTE)`, `valor`, `data_hora`, `descricao`, `transferencia_id (nullable)`

4. **Transferencia**

   * `id`, `origem_conta_id`, `destino_conta_id`, `valor_transferido`, `tarifa`, `data_hora`

5. **SolicitacaoVisita**

   * `id`, `correntista_id`, `data_hora_solicitacao`, `confirmada (boolean)`, `valor_debito (decimal = 50,00)`, `movimentacao_debito_id`

### Relacionamentos

* **Correntista 1:1 ContaCorrente**
* **ContaCorrente 1\:N Movimentacao**
* **Transferencia 1:3 Movimentacoes** (saída, tarifa e entrada)
* **Correntista 1\:N SolicitacaoVisita** (cada visita gera 1 débito em Movimentacao)

---

## Fluxos de Operação

1. **Login:** valida `conta_numero` + `senha`.
2. **Ver Saldo:** leitura direta de `ContaCorrente.saldo`.
3. **Extrato:** lista de `Movimentacao` ordenada por `data_hora DESC`.
4. **Saque:**

   * **NORMAL:** bloqueia se `valor_saque > saldo`.
   * **VIP:** permite saldo negativo; ao ficar negativo, grava `data_hora_primeiro_negativo` e cobra penalidade de 0,1 % ao minuto (sob demanda).
5. **Depósito:** quita penalidades (se houver), lança `Movimentacao` de depósito e atualiza saldo.
6. **Transferência:**

   * **NORMAL:** limite de R\$ 1.000  e tarifa fixa R\$ 8,00.
   * **VIP:** sem limite e tarifa de 0,8 % sobre o valor.
   * Gera três `Movimentacao` (out, tarifa, in).
7. **Solicitação de Visita:** (VIP apenas)

   * Confirmação na UI → cria `SolicitacaoVisita` + lança `Movimentacao` de débito de R\$ 50,00.
8. **Trocar de Usuário:** limpa sessão e retorna ao login.

---

## Estrutura do Projeto

```
├── backend/                # Código Rails
│   ├── app/
│   ├── config/
│   ├── db/
│   └── ...
├── docker-compose.yml
├── start.sh                # Script de inicialização
└── README.md
```

---
## Licença

Este projeto foi desenvolvido para fins de avaliação técnica. Não possui finalidade comercial.


