class CreateDeviceProperties < ActiveRecord::Migration[5.0]
  def change

    create_table :property_types, id: false do |t|
      t.integer :id, null: false, primary_key: true, unsigned: true, auto_increment: true, limit: 1
      t.string :name
    end

    create_table :value_types, id: false do |t|
      t.integer :id, null: false, primary_key: true, unsigned: true, auto_increment: true, limit: 1
      t.integer :property_type_id, null: false, unsigned: true, limit: 1
      t.string :name
    end

    create_table :device_properties, id: false do |t|
      t.integer :id, null: false, primary_key: true, unsigned: true, auto_increment: true
      t.bigint  :device_uid, null: false, unsigned: true
      t.string  :name, null: false
      t.boolean :auto, null: false, default: 0
      t.integer :property_type_id, null: false, unsigned: true, limit: 1
      t.string  :value_min
      t.string  :value_max
      t.string  :property_value

      t.timestamps
    end

		#add_reference :device_properties, :device, index: true # this will create the reference column
		add_foreign_key :device_properties, :devices, column: 'device_uid', primary_key: 'uid'
		add_foreign_key :device_properties, :property_types
		add_foreign_key :value_types, :property_types

  end
end
