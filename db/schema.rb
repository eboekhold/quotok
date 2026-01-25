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

ActiveRecord::Schema[8.1].define(version: 2026_01_25_175201) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"
  enable_extension "vector"

  create_table "quote_sources", force: :cascade do |t|
    t.string "author_field"
    t.datetime "created_at", null: false
    t.string "quote_field"
    t.string "remote_path"
    t.datetime "updated_at", null: false
  end

  create_table "quotes", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.vector "embedding", limit: 1536
    t.bigint "quote_source_id", null: false
    t.text "remote_id", null: false
    t.datetime "updated_at", null: false
    t.index ["quote_source_id"], name: "index_quotes_on_quote_source_id"
  end
end
