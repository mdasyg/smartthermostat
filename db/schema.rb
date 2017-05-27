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

ActiveRecord::Schema.define(version: 20170527080931) do

  create_table "actions", unsigned: true, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer "event_id",       null: false, unsigned: true
    t.integer "property_id",    null: false, unsigned: true
    t.string  "property_value", null: false
    t.index ["event_id"], name: "fk_rails_ff814373b0", using: :btree
    t.index ["property_id"], name: "fk_rails_5473e09386", using: :btree
  end

  create_table "device_properties", unsigned: true, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.bigint   "device_uid",                              null: false, unsigned: true
    t.string   "name",                                    null: false
    t.integer  "value_type_id", limit: 1,                 null: false, unsigned: true
    t.string   "value_min"
    t.string   "value_max"
    t.string   "value"
    t.boolean  "auto",                    default: false, null: false
    t.datetime "created_at",                              null: false
    t.datetime "updated_at",                              null: false
    t.index ["device_uid"], name: "fk_rails_2903da87e3", using: :btree
    t.index ["value_type_id"], name: "fk_rails_56f2035299", using: :btree
  end

  create_table "device_stats", unsigned: true, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.bigint   "device_uid",     null: false, unsigned: true
    t.integer  "stat_id",        null: false
    t.string   "label",          null: false
    t.string   "value"
    t.datetime "last_update_at"
    t.index ["device_uid", "stat_id"], name: "index_device_stats_on_device_uid_and_stat_id", unique: true, using: :btree
  end

  create_table "devices", primary_key: "uid", id: :bigint, default: nil, unsigned: true, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer  "user_id",                       null: false, unsigned: true
    t.string   "name",                          null: false
    t.string   "location",                      null: false
    t.text     "description",     limit: 65535
    t.string   "access_token"
    t.datetime "last_contact_at"
    t.datetime "created_at",                    null: false
    t.datetime "updated_at",                    null: false
    t.index ["access_token"], name: "index_devices_on_access_token", unique: true, using: :btree
    t.index ["user_id"], name: "fk_rails_410b63ef65", using: :btree
  end

  create_table "events", unsigned: true, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.text "description", limit: 65535
  end

  create_table "schedules", unsigned: true, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer  "user_id",                     null: false,                                 unsigned: true
    t.bigint   "device_uid",                  null: false,                                 unsigned: true
    t.integer  "event_id",                    null: false,                                 unsigned: true
    t.datetime "datetime"
    t.integer  "is_recurrent",      limit: 1, null: false,                                 unsigned: true
    t.integer  "recurrence_period",                        comment: "Measured in seconds", unsigned: true
    t.index ["device_uid"], name: "fk_rails_df1268bd4e", using: :btree
    t.index ["event_id"], name: "fk_rails_965f2422fe", using: :btree
    t.index ["user_id"], name: "fk_rails_3c900465fa", using: :btree
  end

  create_table "users", unsigned: true, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string   "email",                              null: false
    t.string   "encrypted_password",                 null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.string   "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string   "unconfirmed_email"
    t.integer  "failed_attempts",        default: 0, null: false
    t.string   "unlock_token"
    t.datetime "locked_at"
    t.datetime "created_at",                         null: false
    t.datetime "updated_at",                         null: false
    t.index ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true, using: :btree
    t.index ["email"], name: "index_users_on_email", unique: true, using: :btree
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree
    t.index ["unlock_token"], name: "index_users_on_unlock_token", unique: true, using: :btree
  end

  create_table "value_types", unsigned: true, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string "name"
  end

  add_foreign_key "actions", "device_properties", column: "property_id"
  add_foreign_key "actions", "events"
  add_foreign_key "device_properties", "devices", column: "device_uid", primary_key: "uid"
  add_foreign_key "device_properties", "value_types"
  add_foreign_key "device_stats", "devices", column: "device_uid", primary_key: "uid"
  add_foreign_key "devices", "users"
  add_foreign_key "schedules", "devices", column: "device_uid", primary_key: "uid"
  add_foreign_key "schedules", "events"
  add_foreign_key "schedules", "users"
end
