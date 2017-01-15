class CreateDeviceProperties < ActiveRecord::Migration[5.0]
  def change
		create_table :value_types, id:false do |t|
			t.integer :id, null: false, primary_key: true, unsigned: true, limit: 1
			t.string :type
		end

		create_table :property_types, id:false do |t|
      t.integer :id, null: false, primary_key: true, unsigned: true, limit: 1
      t.string :type
    end
		
		create_table :device_properties, id: false do |t|
			t.integer :id, null: false, primary_key: true, unsigned: true
      t.bigint  :device_id, unsigned: true, null: false
			t.string  :name, null: false
			t.boolean :auto, null: false, default: 0
			t.integer :property_type, null: false, unsigned: true, limit: 1
			t.integer :value_type, null: false, unsigned: true, limit: 1
			t.string  :value_min
			t.string  :value_max
			t.string  :property_value
    end

		#add_reference :device_properties, :device, index: true # this will create the reference column
		add_foreign_key :device_properties, :devices, column: 'device_id', primary_key: 'uid'
		add_foreign_key :device_properties, :property_types, column: 'property_type'
		add_foreign_key :device_properties, :value_types, column: 'value_type'


  end
end
