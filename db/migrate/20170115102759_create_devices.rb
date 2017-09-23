class CreateDevices < ActiveRecord::Migration[5.0]
  def change
    create_table :devices, id: false do |t|
      t.bigint :uid, null: false, primary_key: true, unsigned: true
      t.integer :user_id, null: false, unsigned: true
      t.integer :type_c_id, null: true, unsigned: true, limit: 1
      t.integer :number_of_schedules, null: true, unsigned: true, limit: 1
      t.string :name, null: false, limit: 25
      t.string :location, null: false, limit: 50
      t.integer :long_offline_time_notification_status, null: false, unsigned: true, limit: 1
      t.text :description
      t.string :access_token, commnent: :has_secure_token
      t.datetime :last_contact_at

      t.timestamps
    end

    add_index :devices, :access_token, unique: true

    add_foreign_key :devices, :users
  end
end
