class CreateSystemEventsRelatedModels < ActiveRecord::Migration[5.0]
  def change

    create_table :actions, id: false do |t|
      t.integer :id, null: false, primary_key: true, unsigned: true, auto_increment: true
      t.integer :device_attribute_id, null: false, unsigned: true
      t.string :device_attribute_value, null: false
    end

    create_table :events, id: false do |t|
      t.integer :id, null: false, primary_key: true, unsigned: true, auto_increment: true
      t.integer :schedule_id, null: false, unsigned: true
      t.integer :action_id, null: false, unsigned: true
    end

    add_index(:events, [:schedule_id, :action_id], { unique: true })

    add_foreign_key :actions, :device_attributes
    add_foreign_key :events, :actions

  end
end
