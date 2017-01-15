class CreateDevices < ActiveRecord::Migration[5.0]
  def change
    create_table :devices do |t|
      t.primary_key{18} :id
      t.string :name
      t.string :location
      t.text :description
      t.string :access_token
      t.datetime :last_contact_at

      t.timestamps
    end
    add_index :devices, :access_token, unique: true
  end
end
