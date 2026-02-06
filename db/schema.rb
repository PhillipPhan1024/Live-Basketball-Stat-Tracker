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

ActiveRecord::Schema[8.1].define(version: 2026_02_06_041357) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "players", force: :cascade do |t|
    t.integer "blocks", default: 0
    t.datetime "created_at", null: false
    t.integer "fga", default: 0
    t.integer "fgm", default: 0
    t.integer "fta", default: 0
    t.integer "ftm", default: 0
    t.string "last_action_gid"
    t.string "name", null: false
    t.integer "points", default: 0
    t.integer "rebounds", default: 0
    t.integer "steals", default: 0
    t.integer "three_pa", default: 0
    t.integer "three_pm", default: 0
    t.integer "turnovers", default: 0
    t.datetime "updated_at", null: false
  end

  create_table "stat_events", force: :cascade do |t|
    t.string "action", null: false
    t.datetime "created_at", null: false
    t.string "group_id"
    t.bigint "player_id", null: false
    t.datetime "updated_at", null: false
    t.integer "value", default: 1
    t.index ["group_id"], name: "index_stat_events_on_group_id"
    t.index ["player_id"], name: "index_stat_events_on_player_id"
  end

  add_foreign_key "stat_events", "players"
end
