class AddFromAppToUsers < ActiveRecord::Migration
  def change
    add_column :users, :from_app, :boolean, default: false
  end
end
