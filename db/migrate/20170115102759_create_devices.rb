class CreateDevices < ActiveRecord::Migration[5.0]
  def change
    create_table :devices, id: false do |t|
      t.bigint :uid, primary_key: true, unsigned: true, limit: 8
      t.string :name, null: false
      t.string :location, null: false
      t.text :description
      t.string :access_token, :commnent => "use 'has_secure_token' for token"
      t.datetime :last_contact_at

      t.timestamps
    end
    add_index :devices, :access_token, unique: true
  end
end
