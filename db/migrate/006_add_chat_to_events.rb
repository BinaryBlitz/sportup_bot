class AddChatToEvents < ActiveRecord::Migration
  def change
    remove_column :events, :chat_id
    add_reference :events, :chat, foreign_key: true
  end
end
