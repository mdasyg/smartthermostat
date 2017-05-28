class CreateValueTypes < ActiveRecord::Migration[5.0]
  def change

    create_table :value_types, id: false do |t|
      t.integer :id, null: false, primary_key: true, unsigned: true, auto_increment: true, limit: 1
      t.integer :primitive_type_id, null: false, unsigned: true, limit: 1
      t.string :name
      t.boolean :unsigned
    end

  end
end