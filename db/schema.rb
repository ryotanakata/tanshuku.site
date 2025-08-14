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

ActiveRecord::Schema[8.0].define(version: 2025_08_14_072706) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "redirect_logs", force: :cascade do |t|
    t.bigint "shortened_url_id", null: false
    t.string "ip_address", null: false
    t.string "country", null: false
    t.string "city", null: false
    t.string "isp", null: false
    t.string "user_agent", null: false
    t.string "referer", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["country"], name: "index_redirect_logs_on_country"
    t.index ["created_at"], name: "index_redirect_logs_on_created_at"
    t.index ["shortened_url_id", "created_at"], name: "index_redirect_logs_on_shortened_url_id_and_created_at"
    t.index ["shortened_url_id"], name: "index_redirect_logs_on_shortened_url_id"
  end

  create_table "shortened_urls", force: :cascade do |t|
    t.string "original_url"
    t.string "short_code"
    t.datetime "deleted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["deleted_at"], name: "index_shortened_urls_on_deleted_at"
    t.index ["short_code"], name: "index_shortened_urls_on_short_code", unique: true
  end

  add_foreign_key "redirect_logs", "shortened_urls"
end
