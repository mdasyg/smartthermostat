class CreateDeviceAttributes < ActiveRecord::Migration[5.0]

  def change
    create_table :device_attributes, id: false do |t|
      t.integer :id, null: false, primary_key: true, unsigned: true, auto_increment: true
      t.bigint :device_uid, null: false, unsigned: true
      t.string :name, null: false
      t.integer :value_type_id, null: false, unsigned: true, limit: 1
      t.string :min_value
      t.string :max_value
      t.string :set_value
      t.string :current_value

      t.timestamps
    end

    add_foreign_key :device_attributes, :devices, column: 'device_uid', primary_key: 'uid'
    add_foreign_key :device_attributes, :value_types

  end

end
