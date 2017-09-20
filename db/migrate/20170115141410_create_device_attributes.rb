class CreateDeviceAttributes < ActiveRecord::Migration[5.0]

  def change
    create_table :device_attributes, id: false do |t|
      t.integer :id, null: false, primary_key: true, unsigned: true, auto_increment: true
      t.bigint :device_uid, null: false, unsigned: true
      t.integer :index_on_device, null: false, unsigned: true, limit: 1
      t.string :name, null: false, limit: 20
      t.integer :primitive_type_c_id, null: false, unsigned: true, limit: 1
      t.integer :direction_c_id, null: false, unsigned: true, limit: 1
      t.string :unit, limit: 5
      t.decimal :min_value, precision: 4, scale: 1
      t.decimal :max_value, precision: 4, scale: 1
      t.decimal :set_value, precision: 4, scale: 1
      t.decimal :current_value, precision: 4, scale: 1

      t.timestamps
    end

    add_foreign_key :device_attributes, :devices, column: 'device_uid', primary_key: 'uid'

  end

end
