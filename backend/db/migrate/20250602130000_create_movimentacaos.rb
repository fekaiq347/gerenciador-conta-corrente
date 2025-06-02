class CreateMovimentacaos < ActiveRecord::Migration[7.1]
  def change
    create_table :movimentacaos do |t|
      t.references :conta_corrente, null: false, foreign_key: true
      t.integer :tipo, null: false
      t.decimal :valor, precision: 12, scale: 2, null:false
      t.datetime :data_hora, null: false
      t.string :descricao, null: false
      t.references :transferencia, null: false, foreign_key: true

      t.timestamps
    end

    # Isso é meio que opcional pra buscar extrato por conta e data
    add_index :movimentacaos, [:conta_corrente_id, :data_hora]
  end
end
