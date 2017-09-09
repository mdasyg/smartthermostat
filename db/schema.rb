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

ActiveRecord::Schema.define(version: 20170906191919) do

  create_table "actions", id: :integer, unsigned: true, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer "device_attribute_id", null: false, unsigned: true
    t.string "device_attribute_start_value", null: false
    t.string "device_attribute_end_value", null: false
    t.index ["device_attribute_id"], name: "fk_rails_6c4d2296a2"
  end

  create_table "device_attributes", id: :integer, unsigned: true, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.bigint "device_uid", null: false, unsigned: true
    t.integer "index_on_device", limit: 1, null: false, unsigned: true
    t.string "name", limit: 20, null: false
    t.integer "primitive_type_c_id", limit: 1, null: false, unsigned: true
    t.integer "direction_c_id", limit: 1, null: false, unsigned: true
    t.string "unit", limit: 5
    t.float "min_value", limit: 24
    t.float "max_value", limit: 24
    t.float "set_value", limit: 24
    t.float "current_value", limit: 24
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["device_uid"], name: "fk_rails_69a3134aba"
  end

  create_table "device_stats", id: :integer, unsigned: true, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.bigint "device_uid", null: false, unsigned: true
    t.string "stat_name", null: false
    t.string "value"
    t.string "label"
    t.datetime "last_update_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["device_uid"], name: "fk_rails_e93e183788"
  end

  create_table "devices", primary_key: "uid", id: :bigint, unsigned: true, default: nil, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer "user_id", null: false, unsigned: true
    t.integer "type_c_id", limit: 1, unsigned: true
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

  create_table "quick_button_actions", id: :integer, unsigned: true, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer "quick_button_id", null: false, unsigned: true
    t.integer "action_id", null: false, unsigned: true
    t.index ["action_id"], name: "fk_rails_b635b11e28"
    t.index ["quick_button_id", "action_id"], name: "index_quick_button_actions_on_quick_button_id_and_action_id", unique: true
  end

  create_table "quick_buttons", id: :integer, unsigned: true, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer "user_id", null: false, unsigned: true
    t.bigint "device_uid", null: false, unsigned: true
    t.integer "index_on_device", limit: 1, null: false, unsigned: true
    t.string "title", null: false
    t.text "description"
    t.integer "duration"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["device_uid"], name: "fk_rails_5f1190818b"
    t.index ["user_id"], name: "fk_rails_abfb5bfc80"
  end

  create_table "schedule_event_actions", id: false, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer "schedule_event_id", null: false, unsigned: true
    t.integer "action_id", null: false, unsigned: true
    t.index ["action_id"], name: "fk_rails_260702085a"
    t.index ["schedule_event_id", "action_id"], name: "index_schedule_event_actions_on_schedule_event_id_and_action_id", unique: true
  end

  create_table "schedule_events", id: :integer, unsigned: true, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer "schedule_id", null: false, unsigned: true
    t.bigint "device_uid", null: false, unsigned: true
    t.index ["device_uid"], name: "fk_rails_07433a881c"
    t.index ["schedule_id", "device_uid"], name: "index_schedule_events_on_schedule_id_and_device_uid", unique: true
  end

  create_table "schedules", id: :integer, unsigned: true, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer "user_id", null: false, unsigned: true
    t.string "title", null: false
    t.text "description"
    t.datetime "start_datetime", null: false
    t.datetime "end_datetime", null: false
    t.integer "priority", limit: 1, unsigned: true
    t.boolean "is_recurrent", null: false, unsigned: true
    t.integer "recurrence_frequency", limit: 1, unsigned: true
    t.integer "recurrence_unit", comment: "Measured in what the \"recurrence_frequency\" says", unsigned: true
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "fk_rails_3c900465fa"
  end

  create_table "smart_thermostat_history_samples", id: :integer, unsigned: true, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.bigint "device_uid", null: false, unsigned: true
    t.date "sample_date", null: false
    t.time "sample_time", null: false
    t.integer "energy_mode", limit: 1, null: false, comment: "If heating, cooling or something else", unsigned: true
    t.integer "energy_source_status", limit: 1, null: false, comment: "Energy source working or not during the sample", unsigned: true
    t.integer "outside_temperature"
    t.float "inside_temperature", limit: 24
    t.float "set_temperature", limit: 24
    t.index ["device_uid", "sample_date", "sample_time"], name: "device_uid_and_sample_date_and_sample_time_unique_idx", unique: true
  end

  create_table "smart_thermostat_training", id: :integer, unsigned: true, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.bigint "device_uid", null: false, unsigned: true
    t.time "sample_time", null: false
    t.integer "outside_temperature"
    t.float "inside_temperature", limit: 24
    t.index ["device_uid", "sample_time", "outside_temperature"], name: "device_uid_and_sample_time_and_outside_temp_unique_idx", unique: true
  end

  create_table "smart_thermostats", id: :integer, unsigned: true, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.bigint "smart_device_uid", null: false, unsigned: true
    t.integer "smart_device_attribute_type_c_id", limit: 1, null: false, unsigned: true
    t.bigint "source_device_uid", null: false, unsigned: true
    t.integer "source_device_attribute_id", null: false, unsigned: true
    t.index ["smart_device_uid", "smart_device_attribute_type_c_id", "source_device_attribute_id"], name: "sm_dev_uid_and_sm_dev_attr_type_and_src_dev_attr_id_unique_idx", unique: true
    t.index ["source_device_attribute_id"], name: "fk_rails_c4ebcce6a0"
    t.index ["source_device_uid"], name: "fk_rails_f1ad4a1a95"
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

  add_foreign_key "actions", "device_attributes"
  add_foreign_key "device_attributes", "devices", column: "device_uid", primary_key: "uid"
  add_foreign_key "device_stats", "devices", column: "device_uid", primary_key: "uid"
  add_foreign_key "devices", "users"
  add_foreign_key "quick_button_actions", "actions"
  add_foreign_key "quick_button_actions", "quick_buttons"
  add_foreign_key "quick_buttons", "devices", column: "device_uid", primary_key: "uid"
  add_foreign_key "quick_buttons", "users"
  add_foreign_key "schedule_event_actions", "actions"
  add_foreign_key "schedule_event_actions", "schedule_events"
  add_foreign_key "schedule_events", "devices", column: "device_uid", primary_key: "uid"
  add_foreign_key "schedule_events", "schedules"
  add_foreign_key "schedules", "users"
  add_foreign_key "smart_thermostat_history_samples", "devices", column: "device_uid", primary_key: "uid"
  add_foreign_key "smart_thermostat_training", "devices", column: "device_uid", primary_key: "uid"
  add_foreign_key "smart_thermostats", "device_attributes", column: "source_device_attribute_id"
  add_foreign_key "smart_thermostats", "devices", column: "smart_device_uid", primary_key: "uid"
  add_foreign_key "smart_thermostats", "devices", column: "source_device_uid", primary_key: "uid"
end
