class CreateSystemEventsRelatedModels < ActiveRecord::Migration[5.0]
  def change

    create_table :actions, id: false do |t|
      t.integer :id, null: false, primary_key: true, unsigned: true, auto_increment: true
      t.integer :property_id, null: false, unsigned: true
      t.string :property_value, null: false
    end

    create_table :events, id: false do |t|
      t.integer :id, null: false, primary_key: true, unsigned: true, auto_increment: true
      t.integer :schedule_id, null: false, unsigned: true
      t.integer :action_id, null: false, unsigned: true
      t.text :description
    end

    # add_index(:actions, [:event_id, :property_id], { unique: true })

    # add_foreign_key :actions, :events
    add_foreign_key :actions, :properties, column: 'property_id'

  end
end
