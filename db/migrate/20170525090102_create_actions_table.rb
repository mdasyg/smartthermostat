class CreateActionsTable < ActiveRecord::Migration[5.0]

  def change
    create_table :actions, id: false do |t|
      t.integer :id, null: false, primary_key: true, unsigned: true, auto_increment: true
      t.integer :device_attribute_id, null: false, unsigned: true
      t.decimal :device_attribute_start_value, null: false, precision: 10, scale: 3
      t.decimal :device_attribute_end_value, null: false, precision: 10, scale: 3
    end

    add_foreign_key(:actions, :device_attributes)

  end

end