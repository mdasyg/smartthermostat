class CreateSmartThermostatRelatedTables < ActiveRecord::Migration[5.1]

  def change

    create_table :smart_thermostats, id: false do |t|
      t.integer :id, null: false, primary_key: true, unsigned: true, auto_increment: true
      t.bigint :smart_device_uid, null: false, unsigned: true
      t.integer :smart_device_attribute_type_c_id, null: false, unsigned: true, limit: 1
      t.bigint :source_device_uid, null: false, unsigned: true
      t.integer :source_device_attribute_id, null: false, unsigned: true
    end

    create_table :smart_thermostat_history_samples, id: false do |t|
      t.integer :id, null: false, primary_key: true, unsigned: true, auto_increment: true
      t.bigint :device_uid, null: false, unsigned: true
      t.date :sample_date, null: false
      t.time :sample_time, null: false
      t.integer :energy_source_status, null: false, unsigned: true, limit: 1, comment: 'Energy source working or not during the sample'
      t.integer :outside_temperature
      t.float :inside_temperature
      t.float :set_temperature
    end

    create_table :smart_thermostat_training, id: false do |t|
      t.integer :id, null: false, primary_key: true, unsigned: true, auto_increment: true
      t.bigint :device_uid, null: false, unsigned: true
      t.time :sample_time, null: false
      t.integer :outside_temperature
      t.float :inside_temperature
    end

    add_index(:smart_thermostats, [:smart_device_uid, :smart_device_attribute_type_c_id, :source_device_attribute_id], { unique: true, name: 'sm_dev_uid_and_sm_dev_attr_type_and_src_dev_attr_id_unique_idx' })
    add_index(:smart_thermostat_history_samples, [:device_uid, :sample_date, :sample_time], { unique: true, name: 'device_uid_and_sample_date_and_sample_time_unique_idx' })
    add_index(:smart_thermostat_training, [:device_uid, :sample_time, :outside_temperature], { unique: true, name: 'device_uid_and_sample_time_and_outside_temp_unique_idx' })

    add_foreign_key(:smart_thermostats, :devices, column: :smart_device_uid, primary_key: :uid)
    add_foreign_key(:smart_thermostats, :devices, column: :source_device_uid, primary_key: :uid)
    add_foreign_key(:smart_thermostats, :device_attributes, column: :source_device_attribute_id)
    add_foreign_key(:smart_thermostat_history_samples, :devices, column: :device_uid, primary_key: :uid)
    add_foreign_key(:smart_thermostat_training, :devices, column: :device_uid, primary_key: :uid)

  end

end
