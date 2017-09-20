class CreateSmartThermostatRelatedTables < ActiveRecord::Migration[5.1]

  def change

    create_table :smart_thermostats, id: false do |t|
      t.integer :id, null: false, primary_key: true, unsigned: true, auto_increment: true
      t.bigint :smart_device_uid, null: false, unsigned: true
      t.integer :smart_device_attribute_type_c_id, null: false, unsigned: true, limit: 1
      t.bigint :source_device_uid, null: false, unsigned: true
      t.integer :source_device_attribute_id, null: false, unsigned: true
    end

    create_table :smart_thermostat_training_set_samples, id: false do |t|
      t.integer :id, null: false, primary_key: true, unsigned: true, auto_increment: true
      t.bigint :device_uid, null: false, unsigned: true
      t.datetime :sample_datetime, null: false
      t.integer :energy_source_status, null: false, unsigned: true, limit: 1, comment: 'Energy source working or not during the sample'
      t.integer :outside_temperature
      t.decimal :inside_temperature, precision: 4, scale: 1
      t.decimal :set_temperature, precision: 4, scale: 1
    end

    create_table :smart_thermostat_computed_datasets, id: false do |t| # _computed_dataset
      t.integer :id, null: false, primary_key: true, unsigned: true, auto_increment: true
      t.bigint :device_uid, null: false, unsigned: true
      t.integer :outside_temperature
      t.decimal :inside_temperature, precision: 4, scale: 1
      t.integer :timeline, null: false, unsigned: true
    end

    add_index(:smart_thermostats, [:smart_device_uid, :smart_device_attribute_type_c_id, :source_device_attribute_id], { unique: true, name: 'sm_dev_uid_and_sm_dev_attr_type_and_src_dev_attr_id_unique_idx' })
    add_index(:smart_thermostat_training_set_samples, [:device_uid, :sample_datetime], { unique: true, name: 'device_uid_and_sample_datetime_unique_idx' })
    add_index(:smart_thermostat_computed_datasets, [:device_uid, :outside_temperature, :inside_temperature], { unique: true, name: 'device_uid_and_outside_temp_and_inside_temperature_unique_idx' })

    add_foreign_key(:smart_thermostats, :devices, column: :smart_device_uid, primary_key: :uid)
    add_foreign_key(:smart_thermostats, :devices, column: :source_device_uid, primary_key: :uid)
    add_foreign_key(:smart_thermostats, :device_attributes, column: :source_device_attribute_id)
    add_foreign_key(:smart_thermostat_training_set_samples, :devices, column: :device_uid, primary_key: :uid)
    add_foreign_key(:smart_thermostat_computed_datasets, :devices, column: :device_uid, primary_key: :uid)

  end

end
