class CreateChats < ActiveRecord::Migration
  def change
    create_table :chats do |t|
      t.string :language
      t.string :chat_id

      t.timestamps null: false
    end
  end
end
