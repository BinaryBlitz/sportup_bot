class AddIndexToChats < ActiveRecord::Migration
  def change
    add_index :chats, :chat_id, unique: true
  end
end
