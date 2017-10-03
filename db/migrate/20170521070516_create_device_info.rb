class CreateDeviceInfos < ActiveRecord::Migration[5.0]
  def change

    create_table :device_infos, id: false do |t|
      t.integer :id, null: false, primary_key: true, unsigned: true, auto_increment: true
      t.bigint  :device_uid, null: false, unsigned: true
      t.string :stat_name, null: false
      t.string :value, null: true, default: nil
      t.string :label, null: true, default: nil
      t.datetime :last_update_at

      t.timestamps
    end

    # add_index( :device_infos, [:device_uid, :stat_id], unique: true )

    add_foreign_key( :device_infos, :devices, column: 'device_uid', primary_key: 'uid' )

  end
end
