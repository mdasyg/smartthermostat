class CreateSchedules < ActiveRecord::Migration[5.0]
  def change

    create_table :schedules, id: false do |t|
      t.integer :id, null: false, primary_key: true, unsigned: true, auto_increment: true
      t.integer :user_id, null: false, unsigned: true
      t.bigint :device_uid, null: false, unsigned: true
      t.datetime :datetime
      t.integer :is_recurrent, null: false, unsigned: true, limit: 1
      t.integer :repeat_every, unsigned: true, limit: 1
      t.integer :recurrence_period, unsigned: true, comment: 'Measured in what the "repeat_every" says'
    end

    add_foreign_key :schedules, :users
    add_foreign_key :schedules, :devices, column: 'device_uid', primary_key: 'uid'
    # add_foreign_key :schedules, :events

  end
end
