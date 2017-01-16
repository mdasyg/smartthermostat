class CreateDevices < ActiveRecord::Migration[5.0]
  def change
    create_table :devices, id: false do |t|
      t.bigint :uid, null: false, primary_key: true, unsigned: true, limit: 8

			t.integer :user_id, null: false, unsigned: true
      t.string :name, null: false
      t.string :location, null: false
      t.text :description
      t.string :access_token, commnent: :has_secure_token
      t.datetime :last_contact_at

      t.timestamps
    end

    add_index :devices, :access_token, unique: true

    add_foreign_key :devices, :users
  end
end
