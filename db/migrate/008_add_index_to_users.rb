class AddIndexToUsers < ActiveRecord::Migration
  def change
    add_index :users, :telegram_id, unique: true
  end
end
