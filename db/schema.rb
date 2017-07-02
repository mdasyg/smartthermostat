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
    t.integer "device_attribute_id",    null: false, unsigned: true
    t.string  "device_attribute_value", null: false
    t.index ["device_attribute_id"], name: "fk_rails_6c4d2296a2", using: :btree
  end

  create_table "device_attributes", unsigned: true, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.bigint   "device_uid",              null: false, unsigned: true
    t.string   "name",                    null: false
    t.integer  "value_type_id", limit: 1, null: false, unsigned: true
    t.string   "min_value"
    t.string   "max_value"
    t.string   "set_value"
    t.string   "current_value"
    t.datetime "created_at",              null: false
    t.datetime "updated_at",              null: false
    t.index ["device_uid"], name: "fk_rails_69a3134aba", using: :btree
    t.index ["value_type_id"], name: "fk_rails_2a67338edb", using: :btree
  end

  create_table "device_stats", unsigned: true, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.bigint   "device_uid",     null: false, unsigned: true
    t.string   "stat_name",      null: false
    t.string   "value"
    t.string   "label"
    t.datetime "last_update_at"
    t.index ["device_uid"], name: "fk_rails_e93e183788", using: :btree
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
    t.integer "schedule_id", null: false, unsigned: true
    t.integer "action_id",   null: false, unsigned: true
    t.index ["action_id"], name: "fk_rails_62e0abe502", using: :btree
    t.index ["schedule_id", "action_id"], name: "index_events_on_schedule_id_and_action_id", unique: true, using: :btree
  end

  create_table "schedules", unsigned: true, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer  "user_id",                         null: false,                                                        unsigned: true
    t.bigint   "device_uid",                      null: false,                                                        unsigned: true
    t.datetime "datetime"
    t.integer  "is_recurrent",      limit: 1,     null: false,                                                        unsigned: true
    t.integer  "repeat_every",      limit: 1,                                                                         unsigned: true
    t.integer  "recurrence_period",                            comment: "Measured in what the \"repeat_every\" says", unsigned: true
    t.text     "description",       limit: 65535
    t.index ["device_uid"], name: "fk_rails_df1268bd4e", using: :btree
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
    t.integer "primitive_type_id", limit: 1, null: false, unsigned: true
    t.string  "name",                        null: false
    t.boolean "unsigned",                    null: false
    t.integer "min_value"
    t.integer "max_value"
  end

  add_foreign_key "actions", "device_attributes"
  add_foreign_key "device_attributes", "devices", column: "device_uid", primary_key: "uid"
  add_foreign_key "device_attributes", "value_types"
  add_foreign_key "device_stats", "devices", column: "device_uid", primary_key: "uid"
  add_foreign_key "devices", "users"
  add_foreign_key "events", "actions"
  add_foreign_key "events", "schedules"
  add_foreign_key "schedules", "devices", column: "device_uid", primary_key: "uid"
  add_foreign_key "schedules", "users"
end
