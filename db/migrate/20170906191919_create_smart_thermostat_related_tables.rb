class CreateSmartThermostatRelatedTables < ActiveRecord::Migration[5.1]

  def change
    create_table :kapws, id: false do |t|
      # t.integer :id, null: false, primary_key: true, unsigned: true, auto_increment: true
      t.bigint :device_uid, null: false, unsigned: true

      t.datetime :when, null: false

      t.integer :energy_mode, null: false, unsigned: true, limit: 1
      t.integer :energy_source_status, null: false, unsigned: true, limit: 1

      t.integer :outside_temperature
      t.float :inside_temperature
      t.float :set_temperature

    end

    add_index(:kapws, [:device_uid, :when], { unique: true })

    add_foreign_key(:kapws, :devices, column: 'device_uid', primary_key: 'uid')

  end

end