class AddTimezoneToChats < ActiveRecord::Migration
  def change
    add_column :chats, :timezone, :string
  end
end
