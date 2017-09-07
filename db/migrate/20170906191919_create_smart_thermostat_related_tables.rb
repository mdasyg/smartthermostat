class CreateSmartThermostatRelatedTables < ActiveRecord::Migration[5.1]

  def change

    create_table :smart_thermostat_device_attributes, id: false  do |t|
      t.integer :id, null: false, primary_key: true, unsigned: true, auto_increment: true
      t.bigint :device_uid, null: false, unsigned: true
      t.integer :device_attribute_id, null: false, unsigned: true
      t.integer :type_c_id, null: false, unsigned: true, limit: 1
    end

    create_table :smart_thermostat_history, id: false do |t|
      t.integer :id, null: false, primary_key: true, unsigned: true, auto_increment: true
      t.bigint :device_uid, null: false, unsigned: true
      t.datetime :sample_datetime, null: false
      t.integer :energy_mode, null: false, unsigned: true, limit: 1, comment: 'If heating, cooling or something else'
      t.integer :energy_source_status, null: false, unsigned: true, limit: 1, comment: 'Energy source woriking or not during the sample'
      t.integer :outside_temperature
      t.float :inside_temperature
      t.float :set_temperature
    end

    add_index(:smart_thermostat_device_attributes, [:device_uid, :device_attribute_id, :type_c_id], { unique: true, name: 'dev_uid_and_dev_attr_id_and_type_c_id_unique_idx' })
    add_index(:smart_thermostat_history, [:device_uid, :sample_datetime], { unique: true })

    # add_foreign_key(:smart_thermostat_device_attributes, :devices, column: 'device_uid', primary_key: 'uid')
    add_foreign_key(:smart_thermostat_device_attributes, :device_attributes)
    add_foreign_key(:smart_thermostat_history, :devices, column: 'device_uid', primary_key: 'uid')

  end

end