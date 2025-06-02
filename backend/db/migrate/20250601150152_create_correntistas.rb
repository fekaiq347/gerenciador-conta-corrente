class CreateCorrentistas < ActiveRecord::Migration[7.1]
  def change
    create_table :correntistas do |t|
      t.string :nome,         null: false
      t.string :conta_numero, null: false, limit: 5
      t.string :senha,        null: false, limit: 4
      t.integer :perfil,      null: false, default: 0

      t.timestamps
    end

    add_index :correntistas, :conta_numero, unique: true
  end
end
