class CreateDeviceStats < ActiveRecord::Migration[5.0]
  def change

    create_table :device_stats, id: false do |t|
      t.integer :id, null: false, primary_key: true, unsigned: true, auto_increment: true
      t.bigint  :device_uid, null: false, unsigned: true
      t.integer :stat_id, null: false
      t.string :label, null: false
      t.string :value, null: true, default: nil
      t.datetime :last_update_at
    end

    add_index( :device_stats, [:device_uid, :stat_id], unique: true )

    add_foreign_key( :device_stats, :devices, column: 'device_uid', primary_key: 'uid' )

  end
end
