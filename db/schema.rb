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

ActiveRecord::Schema[7.2].define(version: 2024_09_30_141137) do
  create_table "stacks", force: :cascade do |t|
    t.string "name", null: false
    t.string "uuid", null: false
    t.string "git_repository", null: false
    t.string "git_reference", null: false
    t.string "git_username"
    t.string "git_token"
    t.string "compose_file", null: false
    t.text "compose_variables"
    t.text "compose_includes"
    t.string "strategy", null: false
    t.integer "polling_interval"
    t.string "signature_header"
    t.string "signature_secret"
    t.integer "processed", default: 0
    t.integer "failed", default: 0
    t.datetime "last_run"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_stacks_on_name", unique: true
    t.index ["uuid"], name: "index_stacks_on_uuid", unique: true
  end
end
