class CreateSolicitacaoVisitas < ActiveRecord::Migration[7.1]
  def change
    create_table :solicitacao_visitas do |t|
      t.references :correntista, null: false, foreign_key: { to_table: :correntistas }
      t.datetime :data_hora_solicitacao, null: false
      t.boolean :confirmada, null: false, default: false
      t.decimal :valor_debito, precision: 12, scale: 2, null: false, default: "50.0"
      t.references :movimentacao_debito, null: true, foreign_key: { to_table: :movimentacaos }, index: { unique: true }

      t.timestamps
    end

    # Índice em correntista_id para consultas
    # add_index :solicitacao_visitas, :correntista_id

    # Índice único para garantir que cada mov de débito seja associada a uma solicitação só
    # add_index :solicitacao_visitas, :movimentacao_debito_id, unique: true
  end
end
