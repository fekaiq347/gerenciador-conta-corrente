class CreateTransferencias < ActiveRecord::Migration[7.1]
  def change
    create_table :transferencias do |t|
      t.integer :origem_conta_id, null: false
      t.integer :destino_conta_id, null: false
      t.decimal :valor_transferido, precision: 12, scale: 2, null: false
      t.decimal :tarifa, precision: 12, scale: 2, null: false, default: "0.0"
      t.datetime :data_hora, null: false

      t.timestamps
    end

  add_index :transferencias, :origem_conta_id
  add_index :transferencias, :destino_conta_id

  add_foreign_key :transferencias, :conta_correntes, column: :origem_conta_id
  add_foreign_key :transferencias, :conta_correntes, column: :destino_conta_id

  add_index :transferencias, %i[origem_conta_id destino_conta_id]
  end
end
