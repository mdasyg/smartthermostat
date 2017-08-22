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

    create_table :quick_button_actions, id: false do |t|
      t.integer :id, null: false, primary_key: true, unsigned: true, auto_increment: true
      t.integer :quick_button_id, null: false, unsigned: true
      t.integer :action_id, null: false, unsigned: true
    end

    add_foreign_key(:quick_buttons, :users)
    add_foreign_key(:quick_buttons, :devices, column: 'device_uid', primary_key: 'uid')

    add_foreign_key(:quick_button_actions, :quick_buttons)
    add_foreign_key(:quick_button_actions, :actions)
  end

end
