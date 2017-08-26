class CreateDeviceAttributes < ActiveRecord::Migration[5.0]

  def change
    create_table :device_attributes, id: false do |t|
      t.integer :id, null: false, primary_key: true, unsigned: true, auto_increment: true
      t.bigint :device_uid, null: false, unsigned: true
      t.string :name, null: false, limit: 20
      t.integer :primitive_type_c_id, null: false, unsigned: true, limit: 1
      t.integer :direction_c_id, null: false, unsigned: true, limit: 1
      t.string :unit, limit: 5
      t.float :min_value
      t.float :max_value
      t.float :set_value
      t.float :current_value

      t.timestamps
    end

    add_foreign_key :device_attributes, :devices, column: 'device_uid', primary_key: 'uid'

  end

end
