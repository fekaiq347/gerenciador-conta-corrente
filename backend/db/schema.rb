# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[7.1].define(version: 2025_06_02_193755) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "conta_correntes", force: :cascade do |t|
    t.bigint "correntista_id", null: false
    t.decimal "saldo", precision: 12, scale: 2, default: "0.0", null: false
    t.boolean "esta_negativo", default: false, null: false
    t.datetime "data_hora_primeiro_negativo"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["correntista_id"], name: "index_conta_correntes_on_correntista_id", unique: true
  end

  create_table "correntistas", force: :cascade do |t|
    t.string "nome", null: false
    t.string "conta_numero", limit: 5, null: false
    t.string "senha", limit: 4, null: false
    t.integer "perfil", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.decimal "saldo", precision: 10, scale: 2, default: "0.0", null: false
    t.index ["conta_numero"], name: "index_correntistas_on_conta_numero", unique: true
  end

  create_table "movimentacaos", force: :cascade do |t|
    t.bigint "conta_corrente_id", null: false
    t.integer "tipo", null: false
    t.decimal "valor", precision: 12, scale: 2, null: false
    t.datetime "data_hora", null: false
    t.string "descricao", null: false
    t.bigint "transferencia_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["conta_corrente_id", "data_hora"], name: "index_movimentacaos_on_conta_corrente_id_and_data_hora"
    t.index ["conta_corrente_id"], name: "index_movimentacaos_on_conta_corrente_id"
    t.index ["transferencia_id"], name: "index_movimentacaos_on_transferencia_id"
  end

  create_table "solicitacao_visitas", force: :cascade do |t|
    t.bigint "correntista_id", null: false
    t.datetime "data_hora_solicitacao", null: false
    t.boolean "confirmada", default: false, null: false
    t.decimal "valor_debito", precision: 12, scale: 2, default: "50.0", null: false
    t.bigint "movimentacao_debito_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["correntista_id"], name: "index_solicitacao_visitas_on_correntista_id"
    t.index ["movimentacao_debito_id"], name: "index_solicitacao_visitas_on_movimentacao_debito_id", unique: true
  end

  create_table "transferencias", force: :cascade do |t|
    t.integer "origem_conta_id", null: false
    t.integer "destino_conta_id", null: false
    t.decimal "valor_transferido", precision: 12, scale: 2, null: false
    t.decimal "tarifa", precision: 12, scale: 2, default: "0.0", null: false
    t.datetime "data_hora", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["destino_conta_id"], name: "index_transferencias_on_destino_conta_id"
    t.index ["origem_conta_id", "destino_conta_id"], name: "index_transferencias_on_origem_conta_id_and_destino_conta_id"
    t.index ["origem_conta_id"], name: "index_transferencias_on_origem_conta_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "name"
    t.string "email"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_foreign_key "conta_correntes", "correntistas"
  add_foreign_key "movimentacaos", "conta_correntes"
  add_foreign_key "movimentacaos", "transferencias"
  add_foreign_key "solicitacao_visitas", "correntistas"
  add_foreign_key "solicitacao_visitas", "movimentacaos", column: "movimentacao_debito_id"
  add_foreign_key "transferencias", "conta_correntes", column: "destino_conta_id"
  add_foreign_key "transferencias", "conta_correntes", column: "origem_conta_id"
end
