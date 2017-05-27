class CreateSystemEventsRelatedModels < ActiveRecord::Migration[5.0]
  def change

    create_table :actions, id: false do |t|
      t.integer :id, null: false, primary_key: true, unsigned: true, auto_increment: true
      t.integer :event_id, null: false, unsigned: true
      t.integer :property_id, null: false, unsigned: true
      t.string :property_value, null: false
    end

    create_table :events, id: false do |t|
      t.integer :id, null: false, primary_key: true, unsigned: true, auto_increment: true
      t.text :description
    end

    add_foreign_key :actions, :events
    add_foreign_key :actions, :device_properties, column: 'property_id'

  end
end