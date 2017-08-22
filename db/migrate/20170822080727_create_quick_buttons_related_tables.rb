class CreateQuickButtonsRelatedTables < ActiveRecord::Migration[5.1]

  def change
    create_table :quick_buttons, id: false do |t|
      t.integer :id, null: false, primary_key: true, unsigned: true, auto_increment: true
      t.integer :user_id, null: false, unsigned: true
      t.bigint :device_uid, null: false, unsigned: true
      t.string :title, null: false
      t.text :description
      t.integer :duration
    end
  end

end
