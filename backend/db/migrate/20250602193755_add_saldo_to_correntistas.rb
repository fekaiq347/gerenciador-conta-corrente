class AddSaldoToCorrentistas < ActiveRecord::Migration[7.1]
  def change
    add_column :correntistas, :saldo, :decimal, precision: 10, scale: 2, default: 0.0, null: false
  end
end
