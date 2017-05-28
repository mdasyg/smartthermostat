class CreateDeviceProperties < ActiveRecord::Migration[5.0]
  def change
    create_table :device_properties, id: false do |t|
      t.integer :id, null: false, primary_key: true, unsigned: true, auto_increment: true
      t.bigint :device_uid, null: false, unsigned: true
      t.string :name, null: false
      t.integer :value_type_id, null: false, unsigned: true, limit: 1
      t.string :value_min
      t.string :value_max
      t.string :value
      t.boolean :auto, null: false, default: 0

      t.timestamps
    end

    add_foreign_key :device_properties, :devices, column: 'device_uid', primary_key: 'uid'
    add_foreign_key :device_properties, :value_types

  end
end
