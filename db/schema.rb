# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20170527060931) do

  create_table "actions", id: :integer, unsigned: true, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer "device_attribute_id", null: false, unsigned: true
    t.string "device_attribute_start_value", null: false
    t.string "device_attribute_end_value", null: false
    t.index ["device_attribute_id"], name: "fk_rails_6c4d2296a2"
  end

  create_table "device_attributes", id: :integer, unsigned: true, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.bigint "device_uid", null: false, unsigned: true
    t.string "name", null: false
    t.integer "value_type_id", limit: 1, null: false, unsigned: true
    t.string "min_value"
    t.string "max_value"
    t.string "set_value"
    t.string "current_value"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["device_uid"], name: "fk_rails_69a3134aba"
    t.index ["value_type_id"], name: "fk_rails_2a67338edb"
  end

  create_table "device_stats", id: :integer, unsigned: true, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.bigint "device_uid", null: false, unsigned: true
    t.string "stat_name", null: false
    t.string "value"
    t.string "label"
    t.datetime "last_update_at"
    t.index ["device_uid"], name: "fk_rails_e93e183788"
  end

  create_table "devices", primary_key: "uid", id: :bigint, unsigned: true, default: nil, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer "user_id", null: false, unsigned: true
    t.string "name", null: false
    t.string "location", null: false
    t.text "description"
    t.string "access_token"
    t.datetime "last_contact_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["access_token"], name: "index_devices_on_access_token", unique: true
    t.index ["user_id"], name: "fk_rails_410b63ef65"
  end

  create_table "schedule_events", id: :integer, unsigned: true, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer "schedule_id", null: false, unsigned: true
    t.bigint "device_uid", null: false, unsigned: true
    t.index ["device_uid"], name: "fk_rails_07433a881c"
    t.index ["schedule_id", "device_uid"], name: "index_schedule_events_on_schedule_id_and_device_uid", unique: true
  end

  create_table "schedule_events_actions", id: false, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer "schedule_event_id", null: false, unsigned: true
    t.integer "action_id", null: false, unsigned: true
    t.index ["action_id"], name: "fk_rails_0dc9a5e5a1"
    t.index ["schedule_event_id", "action_id"], name: "index_schedule_events_actions_on_schedule_event_id_and_action_id", unique: true
  end

  create_table "schedules", id: :integer, unsigned: true, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer "user_id", null: false, unsigned: true
    t.string "title", null: false
    t.text "description"
    t.datetime "start_datetime", null: false
    t.datetime "end_datetime", null: false
    t.integer "priority", limit: 1, unsigned: true
    t.integer "is_recurrent", limit: 1, null: false, unsigned: true
    t.integer "repeat_every", limit: 1, unsigned: true
    t.integer "recurrence_period", comment: "Measured in what the \"repeat_every\" says", unsigned: true
    t.index ["user_id"], name: "fk_rails_3c900465fa"
  end

  create_table "users", id: :integer, unsigned: true, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string "email", null: false
    t.string "encrypted_password", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string "current_sign_in_ip"
    t.string "last_sign_in_ip"
    t.string "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string "unconfirmed_email"
    t.integer "failed_attempts", default: 0, null: false
    t.string "unlock_token"
    t.datetime "locked_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.index ["unlock_token"], name: "index_users_on_unlock_token", unique: true
  end

  create_table "value_types", id: :integer, limit: 1, unsigned: true, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer "primitive_type_id", limit: 1, null: false, unsigned: true
    t.string "name", null: false
    t.boolean "unsigned", null: false
    t.integer "min_value"
    t.integer "max_value"
  end

  add_foreign_key "actions", "device_attributes"
  add_foreign_key "device_attributes", "devices", column: "device_uid", primary_key: "uid"
  add_foreign_key "device_attributes", "value_types"
  add_foreign_key "device_stats", "devices", column: "device_uid", primary_key: "uid"
  add_foreign_key "devices", "users"
  add_foreign_key "schedule_events", "devices", column: "device_uid", primary_key: "uid"
  add_foreign_key "schedule_events", "schedules"
  add_foreign_key "schedule_events_actions", "actions"
  add_foreign_key "schedule_events_actions", "schedule_events"
  add_foreign_key "schedules", "users"
end
