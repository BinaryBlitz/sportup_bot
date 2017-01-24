class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string :telegram_id
      t.string :first_name
      t.string :username
      t.string :last_name
      t.integer :guests_count, default: 0
      t.jsonb :bot_command_data, default: {}

      t.timestamps null: false
    end
  end
end
