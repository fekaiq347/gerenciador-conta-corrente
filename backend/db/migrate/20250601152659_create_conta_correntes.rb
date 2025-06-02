class CreateContaCorrentes < ActiveRecord::Migration[7.1]
  def change
    create_table :conta_correntes do |t|
      t.references :correntista, null: false, foreign_key: {to_table: :correntistas }
      t.decimal :saldo, precision: 12, scale: 2, null: false, default: "0.0"
      t.boolean :esta_negativo, null: false, default: false
      t.datetime :data_hora_primeiro_negativo

      t.timestamps
    end
  end
end
