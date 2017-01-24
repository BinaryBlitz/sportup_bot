class CreateEvents < ActiveRecord::Migration
  def change
    create_table :events do |t|
      t.string :name
      t.string :address
      t.datetime :starting_date
      t.time :starts_at
      t.time :ends_at
      t.integer :user_limit
      t.string :chat_id

      t.timestamps null: false
    end
  end
end
