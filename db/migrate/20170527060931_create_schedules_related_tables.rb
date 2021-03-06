class CreateSchedulesRelatedTables < ActiveRecord::Migration[5.0]

  def change
    create_table :schedules, id: false do |t|
      t.integer :id, null: false, primary_key: true, unsigned: true, auto_increment: true
      t.integer :user_id, null: false, unsigned: true
      t.string :title, null: false
      t.text :description
      t.datetime :start_datetime, null: false
      t.datetime :end_datetime, null: false
      t.integer :priority, unsigned: true, limit: 1
      t.boolean :is_recurrent, null: false, unsigned: true
      t.integer :recurrence_frequency, unsigned: true, limit: 1, comment: 'Measured in what the "recurrence_unit" says'
      t.integer :recurrence_unit, unsigned: true, limit: 1

      t.timestamps
    end

    create_table :schedule_events, id: false do |t|
      t.integer :id, null: false, primary_key: true, unsigned: true, auto_increment: true
      t.integer :schedule_id, null: false, unsigned: true
      t.bigint :device_uid, null: false, unsigned: true
    end

    create_table :schedule_event_actions, id: false do |t|
      # t.integer :id, null: false, primary_key: true, unsigned: true, auto_increment: true
      t.integer :schedule_event_id, null: false, unsigned: true
      t.integer :action_id, null: false, unsigned: true
    end

    add_index(:schedule_events, [:schedule_id, :device_uid], { unique: true })
    add_index(:schedule_event_actions, [:schedule_event_id, :action_id], { unique: true })

    add_foreign_key(:schedules, :users)
    add_foreign_key(:schedule_events, :schedules)
    add_foreign_key(:schedule_events, :devices, column: 'device_uid', primary_key: 'uid')
    add_foreign_key(:schedule_event_actions, :schedule_events)
    add_foreign_key(:schedule_event_actions, :actions)

  end

end
